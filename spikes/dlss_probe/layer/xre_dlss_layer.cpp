// Spike (D-154): DLSS/DLAA in an unforked Godot 4.7, from a Vulkan layer.
//
// The engine exposes no command buffer and no way to add device extensions, so this layer:
//   1. adds NGX's instance and device extensions when Godot (or the OpenXR runtime) creates them;
//   2. turns one dispatch into an NGX evaluation. The probe's CompositorEffect dispatches a stub
//      compute shader declaring color, depth and velocity as inputs and the output as a storage
//      image, so the engine's render graph orders it after the draws and sets the barriers. The
//      handles travel in the shader's push constants; the layer spots them by a magic number and
//      calls NGX instead of the dispatch.
// Enabled per process: VK_LAYER_PATH=<folder of the manifest> VK_INSTANCE_LAYERS=VK_LAYER_XRE_dlss
#define VK_USE_PLATFORM_WIN32_KHR
#include <vulkan/vulkan.h>
#include <vulkan/vk_layer.h>

#include <nvsdk_ngx_vk.h>
#include <nvsdk_ngx_helpers_vk.h>

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <map>
#include <mutex>
#include <string>
#include <vector>

#define XRE_EXPORT extern "C" __declspec(dllexport)

static const char *PROJECT_ID = "5a1f0d3e-7c42-4f6a-9b1e-2d8c6e4a7f10";
static const uint64_t MAGIC = 0x5852454449534c44ull;

// Same layout as the probe's PackedByteArray: 128 bytes of push constants.
struct Params {
	uint64_t magic;
	uint64_t color_image, color_view;
	uint64_t depth_image, depth_view;
	uint64_t motion_image, motion_view;
	uint64_t output_image, output_view;
	uint32_t color_format, depth_format, motion_format, output_format;
	uint32_t width, height;
	uint32_t layer;
	uint32_t slot;
	float jitter_x, jitter_y;
	float motion_scale_x, motion_scale_y;
	uint32_t reset;
	uint32_t motion_jittered;
};
static_assert(sizeof(Params) == 128, "the push constants' size");

static FILE *g_log = nullptr;
static void logf(const char *format, ...) {
	if (g_log == nullptr) {
		const char *path = getenv("XRE_DLSS_LOG");
		g_log = fopen(path != nullptr ? path : "xre_dlss.log", "w");
		if (g_log == nullptr) {
			return;
		}
	}
	va_list args;
	va_start(args, format);
	vfprintf(g_log, format, args);
	va_end(args);
	fputc('\n', g_log);
	fflush(g_log);
}

static PFN_vkGetInstanceProcAddr g_gipa = nullptr;
static PFN_vkGetDeviceProcAddr g_gdpa = nullptr;
static PFN_vkDestroyInstance g_destroy_instance = nullptr;
static PFN_vkDestroyDevice g_destroy_device = nullptr;
static PFN_vkCmdPushConstants g_push_constants = nullptr;
static PFN_vkCmdDispatch g_dispatch = nullptr;
static PFN_vkEnumerateDeviceExtensionProperties g_enumerate_device_extensions = nullptr;

static VkInstance g_instance = VK_NULL_HANDLE;
static VkPhysicalDevice g_physical = VK_NULL_HANDLE;
static VkDevice g_device = VK_NULL_HANDLE;
static std::wstring g_sdk_path;
static std::wstring g_data_path;
static const wchar_t *g_paths[1];
static NVSDK_NGX_FeatureCommonInfo g_common = {};
static NVSDK_NGX_Parameter *g_params = nullptr;
static bool g_ngx_tried = false;
static bool g_ngx_ready = false;
static std::map<uint32_t, NVSDK_NGX_Handle *> g_features;
static uint64_t g_evaluations = 0;
static bool g_eval_failed = false;
static thread_local Params t_pending = {};
static thread_local VkCommandBuffer t_pending_buffer = VK_NULL_HANDLE;

static std::wstring widen(const char *text) {
	std::wstring out;
	for (const char *c = text; *c != 0; c++) {
		out.push_back(wchar_t(*c));
	}
	return out;
}

static NVSDK_NGX_FeatureDiscoveryInfo discovery() {
	static bool paths_set = false;
	if (!paths_set) {
		const char *sdk = getenv("XRE_DLSS_SDK");
		const char *data = getenv("XRE_DLSS_DATA");
		g_sdk_path = widen(sdk != nullptr ? sdk : ".");
		g_data_path = widen(data != nullptr ? data : ".");
		g_paths[0] = g_sdk_path.c_str();
		g_common.PathListInfo.Path = g_paths;
		g_common.PathListInfo.Length = 1;
		paths_set = true;
	}
	NVSDK_NGX_FeatureDiscoveryInfo info = {};
	info.SDKVersion = NVSDK_NGX_Version_API;
	info.FeatureID = NVSDK_NGX_Feature_SuperSampling;
	info.Identifier.IdentifierType = NVSDK_NGX_Application_Identifier_Type_Project_Id;
	info.Identifier.v.ProjectDesc.ProjectId = PROJECT_ID;
	info.Identifier.v.ProjectDesc.EngineType = NVSDK_NGX_ENGINE_TYPE_CUSTOM;
	info.Identifier.v.ProjectDesc.EngineVersion = "4.7.2";
	info.ApplicationDataPath = g_data_path.c_str();
	info.FeatureInfo = &g_common;
	return info;
}

static VKAPI_ATTR VkResult VKAPI_CALL xre_CreateInstance(const VkInstanceCreateInfo *p_info, const VkAllocationCallbacks *p_alloc, VkInstance *r_instance) {
	VkLayerInstanceCreateInfo *chain = (VkLayerInstanceCreateInfo *)p_info->pNext;
	while (chain != nullptr && !(chain->sType == VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO && chain->function == VK_LAYER_LINK_INFO)) {
		chain = (VkLayerInstanceCreateInfo *)chain->pNext;
	}
	if (chain == nullptr) {
		return VK_ERROR_INITIALIZATION_FAILED;
	}
	g_gipa = chain->u.pLayerInfo->pfnNextGetInstanceProcAddr;
	chain->u.pLayerInfo = chain->u.pLayerInfo->pNext;
	PFN_vkCreateInstance create = (PFN_vkCreateInstance)g_gipa(VK_NULL_HANDLE, "vkCreateInstance");

	std::vector<const char *> extensions(p_info->ppEnabledExtensionNames, p_info->ppEnabledExtensionNames + p_info->enabledExtensionCount);
	NVSDK_NGX_FeatureDiscoveryInfo info = discovery();
	uint32_t count = 0;
	VkExtensionProperties *required = nullptr;
	NVSDK_NGX_Result result = NVSDK_NGX_VULKAN_GetFeatureInstanceExtensionRequirements(&info, &count, &required);
	logf("gate instance: requirements result 0x%08x, %u extensions", (unsigned)result, count);
	for (uint32_t i = 0; i < count; i++) {
		bool present = false;
		for (const char *name : extensions) {
			present = present || strcmp(name, required[i].extensionName) == 0;
		}
		logf("  instance %s: %s", required[i].extensionName, present ? "already on" : "added");
		if (!present) {
			extensions.push_back(required[i].extensionName);
		}
	}
	VkInstanceCreateInfo modified = *p_info;
	modified.enabledExtensionCount = uint32_t(extensions.size());
	modified.ppEnabledExtensionNames = extensions.data();
	VkResult created = create(&modified, p_alloc, r_instance);
	logf("vkCreateInstance: %d", created);
	if (created != VK_SUCCESS) {
		return created;
	}
	g_instance = *r_instance;
	g_destroy_instance = (PFN_vkDestroyInstance)g_gipa(g_instance, "vkDestroyInstance");
	g_enumerate_device_extensions = (PFN_vkEnumerateDeviceExtensionProperties)g_gipa(g_instance, "vkEnumerateDeviceExtensionProperties");
	return VK_SUCCESS;
}

static VKAPI_ATTR void VKAPI_CALL xre_DestroyInstance(VkInstance p_instance, const VkAllocationCallbacks *p_alloc) {
	g_destroy_instance(p_instance, p_alloc);
}

static VKAPI_ATTR VkResult VKAPI_CALL xre_CreateDevice(VkPhysicalDevice p_physical, const VkDeviceCreateInfo *p_info, const VkAllocationCallbacks *p_alloc, VkDevice *r_device) {
	VkLayerDeviceCreateInfo *chain = (VkLayerDeviceCreateInfo *)p_info->pNext;
	while (chain != nullptr && !(chain->sType == VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO && chain->function == VK_LAYER_LINK_INFO)) {
		chain = (VkLayerDeviceCreateInfo *)chain->pNext;
	}
	if (chain == nullptr) {
		return VK_ERROR_INITIALIZATION_FAILED;
	}
	PFN_vkGetInstanceProcAddr gipa = chain->u.pLayerInfo->pfnNextGetInstanceProcAddr;
	PFN_vkGetDeviceProcAddr gdpa = chain->u.pLayerInfo->pfnNextGetDeviceProcAddr;
	chain->u.pLayerInfo = chain->u.pLayerInfo->pNext;
	PFN_vkCreateDevice create = (PFN_vkCreateDevice)gipa(g_instance, "vkCreateDevice");

	std::vector<const char *> extensions(p_info->ppEnabledExtensionNames, p_info->ppEnabledExtensionNames + p_info->enabledExtensionCount);
	logf("godot asks for %u device extensions", p_info->enabledExtensionCount);
	// The per-device query needs the loader's handle of the GPU, which a layer doesn't have: it
	// fails with "Invalid physicalDevice". This older one takes no handles.
	uint32_t instance_count = 0;
	uint32_t count = 0;
	const char **instance_required = nullptr;
	const char **required = nullptr;
	NVSDK_NGX_Result result = NVSDK_NGX_VULKAN_RequiredExtensions(&instance_count, &instance_required, &count, &required);
	logf("gate device: requirements result 0x%08x, %u extensions", (unsigned)result, count);
	for (uint32_t i = 0; i < count; i++) {
		bool present = false;
		for (const char *name : extensions) {
			present = present || strcmp(name, required[i]) == 0;
		}
		logf("  device %s: %s", required[i], present ? "already on" : "added");
		if (!present) {
			extensions.push_back(required[i]);
		}
	}
	VkDeviceCreateInfo modified = *p_info;
	modified.enabledExtensionCount = uint32_t(extensions.size());
	modified.ppEnabledExtensionNames = extensions.data();
	VkResult created = create(p_physical, &modified, p_alloc, r_device);
	logf("vkCreateDevice: %d", created);
	if (created != VK_SUCCESS) {
		return created;
	}
	g_physical = p_physical;
	g_device = *r_device;
	g_gdpa = gdpa;
	g_destroy_device = (PFN_vkDestroyDevice)gdpa(g_device, "vkDestroyDevice");
	g_push_constants = (PFN_vkCmdPushConstants)gdpa(g_device, "vkCmdPushConstants");
	g_dispatch = (PFN_vkCmdDispatch)gdpa(g_device, "vkCmdDispatch");
	return VK_SUCCESS;
}

static VKAPI_ATTR void VKAPI_CALL xre_DestroyDevice(VkDevice p_device, const VkAllocationCallbacks *p_alloc) {
	logf("evaluations: %llu", (unsigned long long)g_evaluations);
	if (g_ngx_ready && p_device == g_device) {
		for (const std::pair<const uint32_t, NVSDK_NGX_Handle *> &feature : g_features) {
			NVSDK_NGX_VULKAN_ReleaseFeature(feature.second);
		}
		g_features.clear();
		NVSDK_NGX_VULKAN_DestroyParameters(g_params);
		NVSDK_NGX_VULKAN_Shutdown1(g_device);
		g_ngx_ready = false;
	}
	g_destroy_device(p_device, p_alloc);
}

static void init_ngx() {
	g_ngx_tried = true;
	NVSDK_NGX_FeatureDiscoveryInfo info = discovery();
	NVSDK_NGX_Result result = NVSDK_NGX_VULKAN_Init_with_ProjectID(PROJECT_ID, NVSDK_NGX_ENGINE_TYPE_CUSTOM, "4.7.2", g_data_path.c_str(),
			g_instance, g_physical, g_device, g_gipa, g_gdpa, &g_common);
	logf("gate init: NVSDK_NGX_VULKAN_Init_with_ProjectID 0x%08x", (unsigned)result);
	if (NVSDK_NGX_FAILED(result)) {
		return;
	}
	result = NVSDK_NGX_VULKAN_GetCapabilityParameters(&g_params);
	logf("gate init: capability parameters 0x%08x", (unsigned)result);
	if (NVSDK_NGX_FAILED(result)) {
		return;
	}
	int available = 0;
	int needs_driver = 0;
	int feature_result = 0;
	NVSDK_NGX_Parameter_GetI(g_params, NVSDK_NGX_Parameter_SuperSampling_Available, &available);
	NVSDK_NGX_Parameter_GetI(g_params, NVSDK_NGX_Parameter_SuperSampling_NeedsUpdatedDriver, &needs_driver);
	NVSDK_NGX_Parameter_GetI(g_params, NVSDK_NGX_Parameter_SuperSampling_FeatureInitResult, &feature_result);
	logf("gate init: DLSS available %d, needs driver %d, init result 0x%08x", available, needs_driver, (unsigned)feature_result);
	g_ngx_ready = available != 0;
}

static void evaluate(VkCommandBuffer p_buffer, const Params &p) {
	if (!g_ngx_tried) {
		init_ngx();
	}
	if (!g_ngx_ready) {
		return;
	}
	NVSDK_NGX_Handle *&feature = g_features[p.slot];
	if (feature == nullptr) {
		NVSDK_NGX_DLSS_Create_Params create = {};
		create.Feature.InWidth = p.width;
		create.Feature.InHeight = p.height;
		create.Feature.InTargetWidth = p.width;
		create.Feature.InTargetHeight = p.height;
		create.Feature.InPerfQualityValue = NVSDK_NGX_PerfQuality_Value_DLAA;
		create.InFeatureCreateFlags = NVSDK_NGX_DLSS_Feature_Flags_IsHDR | NVSDK_NGX_DLSS_Feature_Flags_DepthInverted | NVSDK_NGX_DLSS_Feature_Flags_AutoExposure | (p.motion_jittered != 0 ? NVSDK_NGX_DLSS_Feature_Flags_MVJittered : 0);
		NVSDK_NGX_Result result = NGX_VULKAN_CREATE_DLSS_EXT1(g_device, p_buffer, 1, 1, &feature, g_params, &create);
		logf("gate create: slot %u, %ux%u, result 0x%08x", p.slot, p.width, p.height, (unsigned)result);
		if (NVSDK_NGX_FAILED(result)) {
			feature = nullptr;
			g_ngx_ready = false;
			return;
		}
	}
	VkImageSubresourceRange color_range = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, p.layer, 1 };
	VkImageSubresourceRange depth_range = { VK_IMAGE_ASPECT_DEPTH_BIT, 0, 1, p.layer, 1 };
	VkImageSubresourceRange output_range = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
	NVSDK_NGX_Resource_VK color = NVSDK_NGX_Create_ImageView_Resource_VK((VkImageView)p.color_view, (VkImage)p.color_image, color_range, VkFormat(p.color_format), p.width, p.height, false);
	NVSDK_NGX_Resource_VK depth = NVSDK_NGX_Create_ImageView_Resource_VK((VkImageView)p.depth_view, (VkImage)p.depth_image, depth_range, VkFormat(p.depth_format), p.width, p.height, false);
	NVSDK_NGX_Resource_VK motion = NVSDK_NGX_Create_ImageView_Resource_VK((VkImageView)p.motion_view, (VkImage)p.motion_image, color_range, VkFormat(p.motion_format), p.width, p.height, false);
	NVSDK_NGX_Resource_VK output = NVSDK_NGX_Create_ImageView_Resource_VK((VkImageView)p.output_view, (VkImage)p.output_image, output_range, VkFormat(p.output_format), p.width, p.height, true);
	NVSDK_NGX_VK_DLSS_Eval_Params eval = {};
	eval.Feature.pInColor = &color;
	eval.Feature.pInOutput = &output;
	eval.pInDepth = &depth;
	eval.pInMotionVectors = &motion;
	eval.InJitterOffsetX = p.jitter_x;
	eval.InJitterOffsetY = p.jitter_y;
	eval.InRenderSubrectDimensions = { p.width, p.height };
	eval.InReset = int(p.reset);
	eval.InMVScaleX = p.motion_scale_x;
	eval.InMVScaleY = p.motion_scale_y;
	NVSDK_NGX_Result result = NGX_VULKAN_EVALUATE_DLSS_EXT(p_buffer, feature, g_params, &eval);
	if (NVSDK_NGX_FAILED(result)) {
		if (!g_eval_failed) {
			logf("gate evaluate: result 0x%08x", (unsigned)result);
		}
		g_eval_failed = true;
		return;
	}
	if (g_evaluations == 0) {
		logf("gate evaluate: first evaluation OK, color format %u, depth format %u, motion format %u, layer %u", p.color_format, p.depth_format, p.motion_format, p.layer);
	}
	g_evaluations++;
}

static VKAPI_ATTR void VKAPI_CALL xre_CmdPushConstants(VkCommandBuffer p_buffer, VkPipelineLayout p_layout, VkShaderStageFlags p_stages, uint32_t p_offset, uint32_t p_size, const void *p_values) {
	if (p_size == sizeof(Params) && *(const uint64_t *)p_values == MAGIC) {
		memcpy(&t_pending, p_values, sizeof(Params));
		t_pending_buffer = p_buffer;
	}
	g_push_constants(p_buffer, p_layout, p_stages, p_offset, p_size, p_values);
}

static VKAPI_ATTR void VKAPI_CALL xre_CmdDispatch(VkCommandBuffer p_buffer, uint32_t p_x, uint32_t p_y, uint32_t p_z) {
	if (t_pending_buffer == p_buffer) {
		t_pending_buffer = VK_NULL_HANDLE;
		evaluate(p_buffer, t_pending);
		return;
	}
	g_dispatch(p_buffer, p_x, p_y, p_z);
}

XRE_EXPORT VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL xre_GetDeviceProcAddr(VkDevice p_device, const char *p_name);

XRE_EXPORT VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL xre_GetInstanceProcAddr(VkInstance p_instance, const char *p_name) {
	if (strcmp(p_name, "vkGetInstanceProcAddr") == 0) return (PFN_vkVoidFunction)xre_GetInstanceProcAddr;
	if (strcmp(p_name, "vkGetDeviceProcAddr") == 0) return (PFN_vkVoidFunction)xre_GetDeviceProcAddr;
	if (strcmp(p_name, "vkCreateInstance") == 0) return (PFN_vkVoidFunction)xre_CreateInstance;
	if (strcmp(p_name, "vkDestroyInstance") == 0) return (PFN_vkVoidFunction)xre_DestroyInstance;
	if (strcmp(p_name, "vkCreateDevice") == 0) return (PFN_vkVoidFunction)xre_CreateDevice;
	if (strcmp(p_name, "vkDestroyDevice") == 0) return (PFN_vkVoidFunction)xre_DestroyDevice;
	if (strcmp(p_name, "vkCmdPushConstants") == 0) return (PFN_vkVoidFunction)xre_CmdPushConstants;
	if (strcmp(p_name, "vkCmdDispatch") == 0) return (PFN_vkVoidFunction)xre_CmdDispatch;
	return g_gipa != nullptr ? g_gipa(p_instance, p_name) : nullptr;
}

XRE_EXPORT VKAPI_ATTR PFN_vkVoidFunction VKAPI_CALL xre_GetDeviceProcAddr(VkDevice p_device, const char *p_name) {
	if (strcmp(p_name, "vkGetDeviceProcAddr") == 0) return (PFN_vkVoidFunction)xre_GetDeviceProcAddr;
	if (strcmp(p_name, "vkDestroyDevice") == 0) return (PFN_vkVoidFunction)xre_DestroyDevice;
	if (strcmp(p_name, "vkCmdPushConstants") == 0) return (PFN_vkVoidFunction)xre_CmdPushConstants;
	if (strcmp(p_name, "vkCmdDispatch") == 0) return (PFN_vkVoidFunction)xre_CmdDispatch;
	return g_gdpa != nullptr ? g_gdpa(p_device, p_name) : nullptr;
}
