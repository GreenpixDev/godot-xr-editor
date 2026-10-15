#include "editor_controllers.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/xr_pose.hpp>
#include <godot_cpp/classes/xr_positional_tracker.hpp>
#include <godot_cpp/classes/xr_server.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <cstdio>
#include <algorithm>
#include <cmath>

using namespace godot;

namespace xre {

namespace {

constexpr const char *LOG_PREFIX = "XR Editor: ";
XREEditorControllers *active_controller = nullptr;

struct ActionInfo {
	const char *name;
	const char *localized_name;
	XrActionType type;
};

// Indexed by XREEditorControllers::Action; names double as tracker input names.
constexpr ActionInfo ACTION_INFO[] = {
	{ "aim_pose", "Aim pose", XR_ACTION_TYPE_POSE_INPUT },
	{ "grip_pose", "Grip pose", XR_ACTION_TYPE_POSE_INPUT },
	{ "trigger", "Trigger", XR_ACTION_TYPE_FLOAT_INPUT },
	{ "grip", "Grip", XR_ACTION_TYPE_FLOAT_INPUT },
	{ "primary", "Thumbstick", XR_ACTION_TYPE_VECTOR2F_INPUT },
	{ "primary_click", "Thumbstick click", XR_ACTION_TYPE_BOOLEAN_INPUT },
	{ "ax_button", "A or X button", XR_ACTION_TYPE_BOOLEAN_INPUT },
	{ "by_button", "B or Y button", XR_ACTION_TYPE_BOOLEAN_INPUT },
	{ "menu_button", "Menu button", XR_ACTION_TYPE_BOOLEAN_INPUT },
	{ "haptic", "Haptic feedback", XR_ACTION_TYPE_VIBRATION_OUTPUT },
};

constexpr const char *HAND_PATHS[] = { "/user/hand/left", "/user/hand/right" };

struct Binding {
	XREEditorControllers::Action action;
	const char *path;
};

// Meta Quest via Link (and via SteamVR) reports this profile.
constexpr Binding TOUCH_BINDINGS[] = {
	{ XREEditorControllers::ACTION_HAPTIC, "/user/hand/left/output/haptic" },
	{ XREEditorControllers::ACTION_HAPTIC, "/user/hand/right/output/haptic" },
	{ XREEditorControllers::ACTION_AIM_POSE, "/user/hand/left/input/aim/pose" },
	{ XREEditorControllers::ACTION_AIM_POSE, "/user/hand/right/input/aim/pose" },
	{ XREEditorControllers::ACTION_GRIP_POSE, "/user/hand/left/input/grip/pose" },
	{ XREEditorControllers::ACTION_GRIP_POSE, "/user/hand/right/input/grip/pose" },
	{ XREEditorControllers::ACTION_TRIGGER, "/user/hand/left/input/trigger/value" },
	{ XREEditorControllers::ACTION_TRIGGER, "/user/hand/right/input/trigger/value" },
	{ XREEditorControllers::ACTION_GRIP, "/user/hand/left/input/squeeze/value" },
	{ XREEditorControllers::ACTION_GRIP, "/user/hand/right/input/squeeze/value" },
	{ XREEditorControllers::ACTION_THUMBSTICK, "/user/hand/left/input/thumbstick" },
	{ XREEditorControllers::ACTION_THUMBSTICK, "/user/hand/right/input/thumbstick" },
	{ XREEditorControllers::ACTION_THUMBSTICK_CLICK, "/user/hand/left/input/thumbstick/click" },
	{ XREEditorControllers::ACTION_THUMBSTICK_CLICK, "/user/hand/right/input/thumbstick/click" },
	{ XREEditorControllers::ACTION_AX_BUTTON, "/user/hand/left/input/x/click" },
	{ XREEditorControllers::ACTION_AX_BUTTON, "/user/hand/right/input/a/click" },
	{ XREEditorControllers::ACTION_BY_BUTTON, "/user/hand/left/input/y/click" },
	{ XREEditorControllers::ACTION_BY_BUTTON, "/user/hand/right/input/b/click" },
	{ XREEditorControllers::ACTION_MENU_BUTTON, "/user/hand/left/input/menu/click" },
};

// Every conformant runtime supports this profile: poses, select and menu only.
constexpr Binding SIMPLE_BINDINGS[] = {
	{ XREEditorControllers::ACTION_HAPTIC, "/user/hand/left/output/haptic" },
	{ XREEditorControllers::ACTION_HAPTIC, "/user/hand/right/output/haptic" },
	{ XREEditorControllers::ACTION_AIM_POSE, "/user/hand/left/input/aim/pose" },
	{ XREEditorControllers::ACTION_AIM_POSE, "/user/hand/right/input/aim/pose" },
	{ XREEditorControllers::ACTION_GRIP_POSE, "/user/hand/left/input/grip/pose" },
	{ XREEditorControllers::ACTION_GRIP_POSE, "/user/hand/right/input/grip/pose" },
	{ XREEditorControllers::ACTION_TRIGGER, "/user/hand/left/input/select/click" },
	{ XREEditorControllers::ACTION_TRIGGER, "/user/hand/right/input/select/click" },
	{ XREEditorControllers::ACTION_MENU_BUTTON, "/user/hand/left/input/menu/click" },
	{ XREEditorControllers::ACTION_MENU_BUTTON, "/user/hand/right/input/menu/click" },
};

static_assert(sizeof(ACTION_INFO) / sizeof(ACTION_INFO[0]) == XREEditorControllers::ACTION_MAX, "ACTION_INFO must match the Action enum");
static_assert(sizeof(SIMPLE_BINDINGS) <= sizeof(TOUCH_BINDINGS), "suggest_bindings() sizes its buffer for the largest profile");

// Copies into OpenXR's fixed-size name fields, always null-terminated.
template <size_t N>
void copy_name(char (&r_dst)[N], const char *p_src) {
	std::snprintf(r_dst, N, "%s", p_src);
}

} // namespace

void XREEditorControllers::_on_session_created(uint64_t p_session) {
	api = get_openxr_api();
	instance = reinterpret_cast<XrInstance>(api->get_instance());
	session = reinterpret_cast<XrSession>(p_session);
	UtilityFunctions::print(LOG_PREFIX, "OpenXR session created, setting up controller actions.");

	aim_name = StringName("aim");
	grip_name = StringName("grip");
	trigger_name = StringName(ACTION_INFO[ACTION_TRIGGER].name);
	grip_value_name = StringName(ACTION_INFO[ACTION_GRIP].name);
	primary_name = StringName(ACTION_INFO[ACTION_THUMBSTICK].name);
	primary_click_name = StringName(ACTION_INFO[ACTION_THUMBSTICK_CLICK].name);
	ax_button_name = StringName(ACTION_INFO[ACTION_AX_BUTTON].name);
	by_button_name = StringName(ACTION_INFO[ACTION_BY_BUTTON].name);
	menu_button_name = StringName(ACTION_INFO[ACTION_MENU_BUTTON].name);

	if (!load_functions() || !create_actions() || !suggest_bindings() || !create_action_spaces()) {
		destroy();
		return;
	}

	// Must run before Godot attaches its own list: a session accepts one attach only.
	XrSessionActionSetsAttachInfo attach_info = { XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO };
	attach_info.countActionSets = 1;
	attach_info.actionSets = &action_set;
	if (!check(xrAttachSessionActionSets(session, &attach_info), "attach the controller action set")) {
		destroy();
		return;
	}

	// Trackers are created on the first frame: modules create the session
	// before the engine registers its server singletons, so XRServer can't be
	// reached from an extension yet.
	active = true;
	active_controller = this;
	sync_error_reported = false;
	UtilityFunctions::print(LOG_PREFIX, "controller action set attached to the editor's OpenXR session.");
}

void XREEditorControllers::_on_process() {
	if (!active) {
		return;
	}

	const XrActiveActionSet active_set = { action_set, XR_NULL_PATH };
	XrActionsSyncInfo sync_info = { XR_TYPE_ACTIONS_SYNC_INFO };
	sync_info.countActiveActionSets = 1;
	sync_info.activeActionSets = &active_set;
	const XrResult result = xrSyncActions(session, &sync_info);
	if (XR_FAILED(result)) {
		if (!sync_error_reported) {
			sync_error_reported = true;
			check(result, "sync controller actions");
		}
		return;
	}
	// XR_SESSION_NOT_FOCUSED is a success code: all actions read as inactive,
	// poses come back invalid and the controllers are hidden.

	const XrTime time = static_cast<XrTime>(api->get_predicted_display_time());
	const XrSpace base_space = reinterpret_cast<XrSpace>(api->get_play_space());
	if (time == 0 || base_space == XR_NULL_HANDLE) {
		return;
	}
	if (unlikely(trackers[HAND_LEFT].is_null())) {
		create_trackers();
	}

	for (int hand = 0; hand < HAND_MAX; hand++) {
		XRControllerTracker *tracker = trackers[hand].ptr();
		update_pose(tracker, aim_name, aim_spaces[hand], base_space, time);
		update_pose(tracker, grip_name, grip_spaces[hand], base_space, time);

		const Hand h = static_cast<Hand>(hand);
		tracker->set_input(trigger_name, get_float(ACTION_TRIGGER, h));
		tracker->set_input(grip_value_name, get_float(ACTION_GRIP, h));
		tracker->set_input(primary_name, get_vector2(ACTION_THUMBSTICK, h));
		tracker->set_input(primary_click_name, get_bool(ACTION_THUMBSTICK_CLICK, h));
		tracker->set_input(ax_button_name, get_bool(ACTION_AX_BUTTON, h));
		tracker->set_input(by_button_name, get_bool(ACTION_BY_BUTTON, h));
		tracker->set_input(menu_button_name, get_bool(ACTION_MENU_BUTTON, h));
	}
}

void XREEditorControllers::_on_session_destroyed() {
	destroy();
}

bool XREEditorControllers::pulse(Hand p_hand, double p_amplitude, double p_duration) {
	if (!active || p_hand < HAND_LEFT || p_hand >= HAND_MAX || !std::isfinite(p_amplitude) || !std::isfinite(p_duration) || p_duration <= 0.0) {
		return false;
	}
	XrHapticActionInfo info = { XR_TYPE_HAPTIC_ACTION_INFO };
	info.action = actions[ACTION_HAPTIC];
	info.subactionPath = hand_paths[p_hand];
	XrHapticVibration vibration = { XR_TYPE_HAPTIC_VIBRATION };
	vibration.amplitude = static_cast<float>(std::clamp(p_amplitude, 0.0, 1.0));
	vibration.duration = static_cast<XrDuration>(std::clamp(p_duration, 0.001, 1.0) * 1000000000.0);
	vibration.frequency = XR_FREQUENCY_UNSPECIFIED;
	return xrApplyHapticFeedback(session, &info, reinterpret_cast<const XrHapticBaseHeader *>(&vibration)) == XR_SUCCESS;
}

void XREEditorHaptics::_bind_methods() {
	ClassDB::bind_static_method("XREEditorHaptics", D_METHOD("pulse", "hand", "amplitude", "duration"), &XREEditorHaptics::pulse);
}

bool XREEditorHaptics::pulse(int64_t p_hand, double p_amplitude, double p_duration) {
	if (active_controller == nullptr || p_hand < 0 || p_hand >= XREEditorControllers::HAND_MAX) {
		return false;
	}
	return active_controller->pulse(static_cast<XREEditorControllers::Hand>(p_hand), p_amplitude, p_duration);
}

bool XREEditorControllers::_on_event_polled(const void *p_event) {
	const XrEventDataBuffer *event = static_cast<const XrEventDataBuffer *>(p_event);
	if (active && event->type == XR_TYPE_EVENT_DATA_INTERACTION_PROFILE_CHANGED) {
		log_interaction_profiles();
	}
	return false; // Godot still handles the event itself.
}

#define XRE_LOAD(m_name)                                                                         \
	m_name = reinterpret_cast<PFN_##m_name>(api->get_instance_proc_addr(#m_name));               \
	if (m_name == nullptr) {                                                                     \
		ERR_PRINT(String(LOG_PREFIX) + "OpenXR function " #m_name " is unavailable, no controllers."); \
		return false;                                                                            \
	}

bool XREEditorControllers::load_functions() {
	XRE_LOAD(xrStringToPath);
	XRE_LOAD(xrPathToString);
	XRE_LOAD(xrCreateActionSet);
	XRE_LOAD(xrDestroyActionSet);
	XRE_LOAD(xrCreateAction);
	XRE_LOAD(xrSuggestInteractionProfileBindings);
	XRE_LOAD(xrCreateActionSpace);
	XRE_LOAD(xrDestroySpace);
	XRE_LOAD(xrAttachSessionActionSets);
	XRE_LOAD(xrSyncActions);
	XRE_LOAD(xrGetActionStateBoolean);
	XRE_LOAD(xrGetActionStateFloat);
	XRE_LOAD(xrGetActionStateVector2f);
	XRE_LOAD(xrLocateSpace);
	XRE_LOAD(xrGetCurrentInteractionProfile);
	XRE_LOAD(xrApplyHapticFeedback);
	return true;
}

#undef XRE_LOAD

bool XREEditorControllers::create_actions() {
	for (int hand = 0; hand < HAND_MAX; hand++) {
		hand_paths[hand] = to_path(HAND_PATHS[hand]);
		if (hand_paths[hand] == XR_NULL_PATH) {
			return false;
		}
	}

	XrActionSetCreateInfo set_info = { XR_TYPE_ACTION_SET_CREATE_INFO };
	copy_name(set_info.actionSetName, "xr_editor");
	copy_name(set_info.localizedActionSetName, "XR Editor");
	set_info.priority = 0;
	if (!check(xrCreateActionSet(instance, &set_info, &action_set), "create the controller action set")) {
		return false;
	}

	for (int action = 0; action < ACTION_MAX; action++) {
		XrActionCreateInfo info = { XR_TYPE_ACTION_CREATE_INFO };
		copy_name(info.actionName, ACTION_INFO[action].name);
		copy_name(info.localizedActionName, ACTION_INFO[action].localized_name);
		info.actionType = ACTION_INFO[action].type;
		info.countSubactionPaths = HAND_MAX;
		info.subactionPaths = hand_paths;
		if (!check(xrCreateAction(action_set, &info, &actions[action]), ACTION_INFO[action].name)) {
			return false;
		}
	}
	return true;
}

bool XREEditorControllers::suggest_bindings() {
	struct Profile {
		const char *path;
		const Binding *bindings;
		uint32_t count;
	};
	const Profile profiles[] = {
		{ "/interaction_profiles/oculus/touch_controller", TOUCH_BINDINGS, uint32_t(sizeof(TOUCH_BINDINGS) / sizeof(Binding)) },
		{ "/interaction_profiles/khr/simple_controller", SIMPLE_BINDINGS, uint32_t(sizeof(SIMPLE_BINDINGS) / sizeof(Binding)) },
	};

	bool any_accepted = false;
	for (const Profile &profile : profiles) {
		XrActionSuggestedBinding suggested[sizeof(TOUCH_BINDINGS) / sizeof(Binding)];
		for (uint32_t i = 0; i < profile.count; i++) {
			suggested[i].action = actions[profile.bindings[i].action];
			suggested[i].binding = to_path(profile.bindings[i].path);
		}
		XrInteractionProfileSuggestedBinding info = { XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING };
		info.interactionProfile = to_path(profile.path);
		info.countSuggestedBindings = profile.count;
		info.suggestedBindings = suggested;
		// A runtime may reject a profile it doesn't know; the others still work.
		any_accepted |= check(xrSuggestInteractionProfileBindings(instance, &info), profile.path);
	}
	return any_accepted;
}

bool XREEditorControllers::create_action_spaces() {
	for (int hand = 0; hand < HAND_MAX; hand++) {
		XrActionSpaceCreateInfo info = { XR_TYPE_ACTION_SPACE_CREATE_INFO };
		info.subactionPath = hand_paths[hand];
		info.poseInActionSpace.orientation.w = 1.0f;

		info.action = actions[ACTION_AIM_POSE];
		if (!check(xrCreateActionSpace(session, &info, &aim_spaces[hand]), "create the aim pose space")) {
			return false;
		}
		info.action = actions[ACTION_GRIP_POSE];
		if (!check(xrCreateActionSpace(session, &info, &grip_spaces[hand]), "create the grip pose space")) {
			return false;
		}
	}
	return true;
}

void XREEditorControllers::create_trackers() {
	const char *names[HAND_MAX] = { "left_hand", "right_hand" };
	const char *descriptions[HAND_MAX] = { "Left hand controller (XR Editor)", "Right hand controller (XR Editor)" };
	const XRPositionalTracker::TrackerHand tracker_hands[HAND_MAX] = { XRPositionalTracker::TRACKER_HAND_LEFT, XRPositionalTracker::TRACKER_HAND_RIGHT };

	for (int hand = 0; hand < HAND_MAX; hand++) {
		trackers[hand].instantiate();
		trackers[hand]->set_tracker_name(names[hand]);
		trackers[hand]->set_tracker_desc(descriptions[hand]);
		trackers[hand]->set_tracker_hand(tracker_hands[hand]);
		XRServer::get_singleton()->add_tracker(trackers[hand]);
	}
	UtilityFunctions::print(LOG_PREFIX, "controller trackers left_hand and right_hand added.");
}

void XREEditorControllers::destroy() {
	if (active_controller == this) {
		active_controller = nullptr;
	}
	active = false;
	// Not registered yet if the session dies during startup.
	XRServer *xr_server = Engine::get_singleton()->has_singleton("XRServer") ? XRServer::get_singleton() : nullptr;
	for (int hand = 0; hand < HAND_MAX; hand++) {
		if (trackers[hand].is_valid()) {
			if (xr_server != nullptr) {
				xr_server->remove_tracker(trackers[hand]);
			}
			trackers[hand].unref();
		}
		if (aim_spaces[hand] != XR_NULL_HANDLE) {
			xrDestroySpace(aim_spaces[hand]);
			aim_spaces[hand] = XR_NULL_HANDLE;
		}
		if (grip_spaces[hand] != XR_NULL_HANDLE) {
			xrDestroySpace(grip_spaces[hand]);
			grip_spaces[hand] = XR_NULL_HANDLE;
		}
	}
	// Destroying the set destroys its actions.
	if (action_set != XR_NULL_HANDLE) {
		xrDestroyActionSet(action_set);
		action_set = XR_NULL_HANDLE;
	}
	for (int action = 0; action < ACTION_MAX; action++) {
		actions[action] = XR_NULL_HANDLE;
	}
	session = XR_NULL_HANDLE;
	api.unref();
}

XrPath XREEditorControllers::to_path(const char *p_path) const {
	XrPath path = XR_NULL_PATH;
	check(xrStringToPath(instance, p_path, &path), p_path);
	return path;
}

bool XREEditorControllers::check(XrResult p_result, const char *p_what) const {
	if (XR_SUCCEEDED(p_result)) {
		return true;
	}
	ERR_PRINT(String(LOG_PREFIX) + "failed to " + p_what + ": " + api->get_error_string(static_cast<uint64_t>(static_cast<int64_t>(p_result))));
	return false;
}

void XREEditorControllers::update_pose(XRControllerTracker *p_tracker, const StringName &p_name, XrSpace p_space, XrSpace p_base, XrTime p_time) {
	XrSpaceVelocity velocity = { XR_TYPE_SPACE_VELOCITY };
	XrSpaceLocation location = { XR_TYPE_SPACE_LOCATION, &velocity };
	const XrResult result = xrLocateSpace(p_space, p_base, p_time, &location);

	constexpr XrSpaceLocationFlags valid = XR_SPACE_LOCATION_POSITION_VALID_BIT | XR_SPACE_LOCATION_ORIENTATION_VALID_BIT;
	if (XR_FAILED(result) || (location.locationFlags & valid) != valid) {
		p_tracker->invalidate_pose(p_name);
		return;
	}

	const XrPosef &pose = location.pose;
	const Transform3D transform(
			Basis(Quaternion(pose.orientation.x, pose.orientation.y, pose.orientation.z, pose.orientation.w)),
			Vector3(pose.position.x, pose.position.y, pose.position.z));
	Vector3 linear_velocity;
	Vector3 angular_velocity;
	if (velocity.velocityFlags & XR_SPACE_VELOCITY_LINEAR_VALID_BIT) {
		linear_velocity = Vector3(velocity.linearVelocity.x, velocity.linearVelocity.y, velocity.linearVelocity.z);
	}
	if (velocity.velocityFlags & XR_SPACE_VELOCITY_ANGULAR_VALID_BIT) {
		angular_velocity = Vector3(velocity.angularVelocity.x, velocity.angularVelocity.y, velocity.angularVelocity.z);
	}

	constexpr XrSpaceLocationFlags tracked = XR_SPACE_LOCATION_POSITION_TRACKED_BIT | XR_SPACE_LOCATION_ORIENTATION_TRACKED_BIT;
	const XRPose::TrackingConfidence confidence = (location.locationFlags & tracked) == tracked
			? XRPose::XR_TRACKING_CONFIDENCE_HIGH
			: XRPose::XR_TRACKING_CONFIDENCE_LOW;
	p_tracker->set_pose(p_name, transform, linear_velocity, angular_velocity, confidence);
}

bool XREEditorControllers::get_bool(Action p_action, Hand p_hand) const {
	XrActionStateGetInfo info = { XR_TYPE_ACTION_STATE_GET_INFO };
	info.action = actions[p_action];
	info.subactionPath = hand_paths[p_hand];
	XrActionStateBoolean state = { XR_TYPE_ACTION_STATE_BOOLEAN };
	if (XR_FAILED(xrGetActionStateBoolean(session, &info, &state)) || !state.isActive) {
		return false;
	}
	return state.currentState == XR_TRUE;
}

float XREEditorControllers::get_float(Action p_action, Hand p_hand) const {
	XrActionStateGetInfo info = { XR_TYPE_ACTION_STATE_GET_INFO };
	info.action = actions[p_action];
	info.subactionPath = hand_paths[p_hand];
	XrActionStateFloat state = { XR_TYPE_ACTION_STATE_FLOAT };
	if (XR_FAILED(xrGetActionStateFloat(session, &info, &state)) || !state.isActive) {
		return 0.0f;
	}
	return state.currentState;
}

Vector2 XREEditorControllers::get_vector2(Action p_action, Hand p_hand) const {
	XrActionStateGetInfo info = { XR_TYPE_ACTION_STATE_GET_INFO };
	info.action = actions[p_action];
	info.subactionPath = hand_paths[p_hand];
	XrActionStateVector2f state = { XR_TYPE_ACTION_STATE_VECTOR2F };
	if (XR_FAILED(xrGetActionStateVector2f(session, &info, &state)) || !state.isActive) {
		return Vector2();
	}
	// OpenXR's +Y is up on the stick; Godot's default action map keeps it that way.
	return Vector2(state.currentState.x, state.currentState.y);
}

void XREEditorControllers::log_interaction_profiles() {
	for (int hand = 0; hand < HAND_MAX; hand++) {
		XrInteractionProfileState state = { XR_TYPE_INTERACTION_PROFILE_STATE };
		if (!check(xrGetCurrentInteractionProfile(session, hand_paths[hand], &state), "query the interaction profile")) {
			continue;
		}
		String profile = "none";
		if (state.interactionProfile != XR_NULL_PATH) {
			char buffer[XR_MAX_PATH_LENGTH];
			uint32_t length = 0;
			if (check(xrPathToString(instance, state.interactionProfile, XR_MAX_PATH_LENGTH, &length, buffer), "read the interaction profile")) {
				profile = String(buffer);
			}
		}
		if (trackers[hand].is_valid()) {
			trackers[hand]->set_tracker_profile(profile);
		}
		UtilityFunctions::print(LOG_PREFIX, HAND_PATHS[hand], " interaction profile: ", profile, ".");
	}
}

} // namespace xre
