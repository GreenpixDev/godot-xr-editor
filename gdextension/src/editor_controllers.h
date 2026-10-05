#pragma once

#include <godot_cpp/classes/open_xr_extension_wrapper.hpp>
#include <godot_cpp/classes/open_xrapi_extension.hpp>
#include <godot_cpp/classes/xr_controller_tracker.hpp>
#include <godot_cpp/variant/string_name.hpp>

#include <openxr/openxr.h>

namespace xre {

/// Controller input for the OpenXR session of the Godot editor.
///
/// In the editor, Godot 4.7 loads an empty action map
/// (OpenXRActionMap::create_editor_action_sets() is a TODO), so no controller
/// is tracked. This wrapper creates its own action set and attaches it in
/// _on_session_created(), before Godot attaches its (empty) list, then syncs
/// it every frame and publishes poses and inputs to the "left_hand" and
/// "right_hand" XRControllerTracker, the same names and inputs the default
/// action map uses in a running game. Outside the editor it is never
/// registered and the project's own action map is used.
class XREEditorControllers : public godot::OpenXRExtensionWrapper {
	GDCLASS(XREEditorControllers, godot::OpenXRExtensionWrapper);

public:
	enum Hand {
		HAND_LEFT,
		HAND_RIGHT,
		HAND_MAX,
	};

	/// Actions of the editor's action set. Names of the matching tracker
	/// inputs follow Godot's default action map (see ACTION_INFO).
	enum Action {
		ACTION_AIM_POSE,
		ACTION_GRIP_POSE,
		ACTION_TRIGGER,
		ACTION_GRIP,
		ACTION_THUMBSTICK,
		ACTION_THUMBSTICK_CLICK,
		ACTION_AX_BUTTON,
		ACTION_BY_BUTTON,
		ACTION_MENU_BUTTON,
		ACTION_MAX,
	};

	void _on_session_created(uint64_t p_session) override;
	void _on_process() override;
	void _on_session_destroyed() override;
	bool _on_event_polled(const void *p_event) override;

protected:
	static void _bind_methods() {}

private:
	// OpenXR entry points, resolved through Godot's instance (no loader linking).
	PFN_xrStringToPath xrStringToPath = nullptr;
	PFN_xrPathToString xrPathToString = nullptr;
	PFN_xrCreateActionSet xrCreateActionSet = nullptr;
	PFN_xrDestroyActionSet xrDestroyActionSet = nullptr;
	PFN_xrCreateAction xrCreateAction = nullptr;
	PFN_xrSuggestInteractionProfileBindings xrSuggestInteractionProfileBindings = nullptr;
	PFN_xrCreateActionSpace xrCreateActionSpace = nullptr;
	PFN_xrDestroySpace xrDestroySpace = nullptr;
	PFN_xrAttachSessionActionSets xrAttachSessionActionSets = nullptr;
	PFN_xrSyncActions xrSyncActions = nullptr;
	PFN_xrGetActionStateBoolean xrGetActionStateBoolean = nullptr;
	PFN_xrGetActionStateFloat xrGetActionStateFloat = nullptr;
	PFN_xrGetActionStateVector2f xrGetActionStateVector2f = nullptr;
	PFN_xrLocateSpace xrLocateSpace = nullptr;
	PFN_xrGetCurrentInteractionProfile xrGetCurrentInteractionProfile = nullptr;

	godot::Ref<godot::OpenXRAPIExtension> api;
	XrInstance instance = XR_NULL_HANDLE;
	XrSession session = XR_NULL_HANDLE;
	XrActionSet action_set = XR_NULL_HANDLE;
	XrAction actions[ACTION_MAX] = {};
	XrPath hand_paths[HAND_MAX] = {};
	XrSpace aim_spaces[HAND_MAX] = {};
	XrSpace grip_spaces[HAND_MAX] = {};
	godot::Ref<godot::XRControllerTracker> trackers[HAND_MAX];
	bool active = false;
	bool sync_error_reported = false;

	// Interned once: per-frame code must not allocate.
	godot::StringName aim_name;
	godot::StringName grip_name;
	godot::StringName trigger_name;
	godot::StringName grip_value_name;
	godot::StringName primary_name;
	godot::StringName primary_click_name;
	godot::StringName ax_button_name;
	godot::StringName by_button_name;
	godot::StringName menu_button_name;

	bool load_functions();
	bool create_actions();
	bool suggest_bindings();
	bool create_action_spaces();
	void create_trackers();
	void destroy();

	XrPath to_path(const char *p_path) const;
	bool check(XrResult p_result, const char *p_what) const;

	void update_pose(godot::XRControllerTracker *p_tracker, const godot::StringName &p_name, XrSpace p_space, XrSpace p_base, XrTime p_time);
	bool get_bool(Action p_action, Hand p_hand) const;
	float get_float(Action p_action, Hand p_hand) const;
	godot::Vector2 get_vector2(Action p_action, Hand p_hand) const;
	void log_interaction_profiles();
};

} // namespace xre
