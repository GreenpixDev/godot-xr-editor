#include "editor_frame_loop.h"

#include "frame_timer.h"

#include <openxr/openxr.h>

#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

namespace xre {

namespace {

String timestamp() {
	return String("[") + String::num(Time::get_singleton()->get_ticks_msec() / 1000.0, 3) + " s] ";
}

} // namespace

void XREEditorFrameLoop::_on_session_created(uint64_t) {
	api = get_openxr_api();
	// Makes the engine call _set_frame_wait_info_and_get_next_pointer() before every xrWaitFrame.
	api->register_frame_info_extension(this);
}

void XREEditorFrameLoop::_on_session_destroyed() {
	api->unregister_frame_info_extension(this);
	api.unref();
}

uint64_t XREEditorFrameLoop::_set_frame_wait_info_and_get_next_pointer(void *p_next_pointer) {
	const bool closing = waited_frames > begun_frames.load();
	if (closing) {
		// The previous wait has no begun frame: this wait is nested in an
		// iteration that hasn't drawn yet, or that iteration skipped the draw.
		closed_frames++;
		const int begun_before = begun_frames.load();
		RenderingServer::get_singleton()->force_draw(true, 0.0);
		if (closed_frames <= LOGGED_FRAMES) {
			UtilityFunctions::print(timestamp(), "XR Editor: frame ", waited_frames, " was waited but not begun before the next xrWaitFrame; drew it now: ",
					begun_frames.load() > begun_before ? "begun." : "still not begun.");
		}
	}
	// After the closing draw: its time counts as work of the previous frame.
	XREFrameTimer::on_wait_begin(Time::get_singleton()->get_ticks_usec(), closing);
	return reinterpret_cast<uint64_t>(p_next_pointer);
}

uint64_t XREEditorFrameLoop::_set_frame_end_info_and_get_next_pointer(void *p_next_pointer) {
	// Right before xrEndFrame, when a projection layer is submitted.
	XREFrameTimer::on_frame_end(Time::get_singleton()->get_ticks_usec());
	return reinterpret_cast<uint64_t>(p_next_pointer);
}

void XREEditorFrameLoop::_on_pre_draw_viewport(const RID &) {
	// Only the headset viewport (use_xr) gets here, after its swapchain image was acquired.
	XREFrameTimer::on_xr_swapchain_ready(Time::get_singleton()->get_ticks_usec());
}

void XREEditorFrameLoop::_on_post_draw_viewport(const RID &) {
	XREFrameTimer::on_xr_recorded(Time::get_singleton()->get_ticks_usec());
}

void XREEditorFrameLoop::_on_process() {
	const uint64_t now = Time::get_singleton()->get_ticks_usec();
	XREFrameTimer::on_wait_end(now, session_state, api->can_render());

	OS *os = OS::get_singleton();
	const bool low_processor = os->is_in_low_processor_usage_mode();
	if (low_processor) {
		os->set_low_processor_usage_mode(false);
		if (!low_processor_reported) {
			low_processor_reported = true;
			UtilityFunctions::print("XR Editor: low-processor mode off while the OpenXR session runs: every xrWaitFrame needs a rendered frame.");
		}
	}

	waited_frames++;
	if (waited_frames <= LOGGED_FRAMES) {
		const double since_last_ms = last_wait_usec == 0 ? 0.0 : (now - last_wait_usec) / 1000.0;
		last_wait_usec = now;
		UtilityFunctions::print(timestamp(), "XR Editor: frame ", waited_frames, " waited, ",
				String::num(since_last_ms, 1), " ms after the previous wait, ", begun_frames.load(), " frame(s) begun so far, low-processor mode was ", low_processor, ".");
	}
}

void XREEditorFrameLoop::_on_pre_render() {
	// Called after a successful xrBeginFrame.
	XREFrameTimer::on_frame_begun(Time::get_singleton()->get_ticks_usec());
	const int begun = ++begun_frames;
	if (begun <= LOGGED_FRAMES) {
		UtilityFunctions::print(timestamp(), "XR Editor: frame ", begun, " begun.");
	}
}

void XREEditorFrameLoop::log_state(int p_state, const char *p_name) {
	session_state = p_state;
	UtilityFunctions::print(timestamp(), "XR Editor: OpenXR session state ", p_name, ".");
}

void XREEditorFrameLoop::_on_state_idle() {
	log_state(XR_SESSION_STATE_IDLE, "IDLE");
}

void XREEditorFrameLoop::_on_state_ready() {
	log_state(XR_SESSION_STATE_READY, "READY (session begun)");
}

void XREEditorFrameLoop::_on_state_synchronized() {
	log_state(XR_SESSION_STATE_SYNCHRONIZED, "SYNCHRONIZED");
}

void XREEditorFrameLoop::_on_state_visible() {
	log_state(XR_SESSION_STATE_VISIBLE, "VISIBLE");
}

void XREEditorFrameLoop::_on_state_focused() {
	log_state(XR_SESSION_STATE_FOCUSED, "FOCUSED");
}

void XREEditorFrameLoop::_on_state_stopping() {
	log_state(XR_SESSION_STATE_STOPPING, "STOPPING");
}

void XREEditorFrameLoop::_on_state_loss_pending() {
	log_state(XR_SESSION_STATE_LOSS_PENDING, "LOSS_PENDING");
}

void XREEditorFrameLoop::_on_state_exiting() {
	log_state(XR_SESSION_STATE_EXITING, "EXITING");
}

} // namespace xre
