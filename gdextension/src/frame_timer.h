#pragma once

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/rid.hpp>
#include <godot_cpp/variant/typed_array.hpp>

#include <cstdint>

namespace xre {

/// Per-frame timing of the editor's OpenXR frame loop, for the spike's frame
/// budget measurement (docs/plan.md: 11.1 ms at 90 Hz).
///
/// XREEditorFrameLoop reports the phases of every frame; while a segment is
/// being recorded each frame goes into a buffer preallocated by start(), so
/// recording neither allocates nor touches the disk. All segments of a run share
/// that buffer and save_csv() writes them in one go at the end: a file write
/// between segments stalls the main loop and can make the runtime drop to half
/// rate (observed 2026-10-05). Driven from GDScript (XREFrameBenchmark), main
/// thread only (the editor always renders on the main thread).
///
/// CSV columns, per frame (times in ms; empty when a phase didn't happen):
/// - segment, variant: as given to begin_segment();
/// - t_ms: since the segment's first frame;
/// - interval_ms: from the previous xrWaitFrame return to this one (display pacing);
/// - wait_ms: time blocked in this xrWaitFrame;
/// - cpu_ms: main-thread time from this xrWaitFrame return to the next xrWaitFrame call,
///   split into the following phases:
///   - process_ms: physics and SceneTree process, i.e. the editor's own logic, until
///     the RenderingServer starts drawing (xrBeginFrame done);
///   - swapchain_ms: from there until the headset's swapchain image is acquired,
///     including the wait for the compositor to release it and any viewport drawn first;
///   - xr_record_ms: recording the headset viewport;
///   - submit_ms: the rest of the draw until xrEndFrame;
///   - after_ms: from xrEndFrame to the next xrWaitFrame (desktop present, end of iteration);
/// - gpu_xr_ms, gpu_desktop_ms, gpu_ms: GPU time measured by the RenderingServer
///   for the headset viewport, the given desktop viewports and their sum; the latest
///   measurements available at this frame, i.e. one or two frames old;
/// - session_state: XrSessionState (4 VISIBLE, 5 FOCUSED);
/// - can_render: the runtime asked for this frame to be rendered;
/// - closed_before_wait: a frame left unbegun was drawn right before the next wait
///   (nested Main::iteration, see XREEditorFrameLoop).
class XREFrameTimer : public godot::Object {
	GDCLASS(XREFrameTimer, godot::Object);

public:
	/// Clears the buffer and makes room for p_max_frames frames over the whole run.
	static bool start(int64_t p_max_frames);
	/// Records the following frames as segment p_segment of variant p_variant.
	/// GPU time is read from p_xr_viewport and summed over p_desktop_viewports,
	/// which must be the desktop viewports that actually render: a viewport that
	/// stops rendering keeps reporting its last measurement.
	static void begin_segment(int64_t p_segment, const godot::String &p_variant, const godot::RID &p_xr_viewport, const godot::TypedArray<godot::RID> &p_desktop_viewports);
	/// Stops recording until the next begin_segment().
	static void end_segment();
	/// Ends recording and returns the number of frames recorded.
	static int64_t stop();
	static bool is_recording();
	static godot::Error save_csv(const godot::String &p_path);

	// Fed by XREEditorFrameLoop on the main thread, in this order per frame.
	static void on_wait_begin(uint64_t p_usec, bool p_closed_frame);
	static void on_wait_end(uint64_t p_usec, int p_session_state, bool p_can_render);
	static void on_frame_begun(uint64_t p_usec);
	static void on_xr_swapchain_ready(uint64_t p_usec);
	static void on_xr_recorded(uint64_t p_usec);
	static void on_frame_end(uint64_t p_usec);

protected:
	static void _bind_methods();
};

} // namespace xre
