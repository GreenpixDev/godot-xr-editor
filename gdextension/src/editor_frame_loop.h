#pragma once

#include <godot_cpp/classes/open_xr_extension_wrapper.hpp>
#include <godot_cpp/classes/open_xrapi_extension.hpp>

#include <atomic>
#include <cstdint>

namespace xre {

/// Keeps the editor's main loop a valid OpenXR frame loop.
///
/// Godot assumes one xrWaitFrame (XRServer::_process) per RenderingServer
/// draw (xrBeginFrame/xrEndFrame) in every Main::iteration(). The editor breaks
/// that in two ways:
/// - low-processor mode skips the draw when nothing on screen changed;
/// - progress dialogs and a few other editor paths call Main::iteration()
///   from inside an iteration, so a nested xrWaitFrame comes before the outer
///   frame was begun. By the spec that wait blocks until the previous frame
///   begins, which a single-threaded loop never does; the Meta runtime gives
///   up after ~30 s with XR_ERROR_RUNTIME_FAILURE and loses the session
///   (observed 2026-10-05 during the editor's "Project initialization").
///
/// So low-processor mode is turned off after every wait (_on_process), and
/// right before every wait any frame that was waited but not begun is drawn
/// through the engine's own path (RenderingServer::force_draw). The outer
/// iteration's own draw then fails with XR_ERROR_CALL_ORDER_INVALID, which is
/// logged by the engine and otherwise harmless. Restoring low-processor mode
/// after the session ends is up to the plugin (XRESession).
///
/// Also feeds XREFrameTimer with the phases of every frame.
///
/// Spike diagnostics: logs every session state change, the first frames and
/// the first closed frames with timestamps. Frame counting starts over with
/// every session: the plugin may destroy the session and create a new one
/// while the editor runs (XRESession.release_session).
class XREEditorFrameLoop : public godot::OpenXRExtensionWrapper {
	GDCLASS(XREEditorFrameLoop, godot::OpenXRExtensionWrapper);

public:
	void _on_session_created(uint64_t p_session) override;
	void _on_session_destroyed() override;
	uint64_t _set_frame_wait_info_and_get_next_pointer(void *p_next_pointer) override;
	uint64_t _set_frame_end_info_and_get_next_pointer(void *p_next_pointer) override;
	void _on_pre_draw_viewport(const godot::RID &p_viewport) override;
	void _on_post_draw_viewport(const godot::RID &p_viewport) override;
	void _on_process() override;
	void _on_pre_render() override;
	void _on_state_idle() override;
	void _on_state_ready() override;
	void _on_state_synchronized() override;
	void _on_state_visible() override;
	void _on_state_focused() override;
	void _on_state_stopping() override;
	void _on_state_loss_pending() override;
	void _on_state_exiting() override;

protected:
	static void _bind_methods() {}

private:
	/// Frames and closed frames logged in detail after the session begins.
	static constexpr int LOGGED_FRAMES = 12;

	godot::Ref<godot::OpenXRAPIExtension> api;
	/// XrSessionState of the latest state change.
	int session_state = 0;
	bool low_processor_reported = false;
	int waited_frames = 0;
	int closed_frames = 0;
	uint64_t last_wait_usec = 0;
	// _on_pre_render runs on the render thread (the main thread in the editor).
	std::atomic<int> begun_frames = 0;

	void log_state(int p_state, const char *p_name);
};

} // namespace xre
