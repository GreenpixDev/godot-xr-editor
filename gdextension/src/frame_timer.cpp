#include "frame_timer.h"

#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>

#include <string>
#include <vector>

using namespace godot;

namespace xre {

namespace {

struct Frame {
	int segment;
	uint64_t wait_begin_usec;
	uint64_t wait_end_usec;
	// 0 until the phase happens.
	uint64_t begun_usec;
	uint64_t swapchain_ready_usec;
	uint64_t recorded_usec;
	uint64_t end_usec;
	uint64_t next_wait_begin_usec;
	double gpu_xr_ms;
	double gpu_desktop_ms;
	int session_state;
	bool can_render;
	bool closed_before_wait;
};

// No Godot-owned types (String, Array...): this static outlives the engine at shutdown.
struct Recorder {
	std::vector<Frame> frames;
	size_t max_frames = 0;
	bool recording = false;
	int segment = 0;
	std::vector<std::string> variants; // Indexed by segment.
	RID xr_viewport;
	std::vector<RID> desktop_viewports;
	uint64_t pending_wait_begin_usec = 0;
	bool pending_closed = false;

	/// The frame of the current segment whose phases are being filled in, if any.
	/// The last frame of an earlier segment stays without an end: it must not get one.
	Frame *current() {
		if (frames.empty() || frames.back().segment != segment || frames.back().next_wait_begin_usec != 0) {
			return nullptr;
		}
		return &frames.back();
	}
};

Recorder &recorder() {
	static Recorder instance;
	return instance;
}

String ms(double p_value) {
	return String::num(p_value, 3);
}

/// Duration between two timestamps, or an empty field if either is missing.
String span(uint64_t p_from, uint64_t p_to) {
	return p_from == 0 || p_to == 0 || p_to < p_from ? String() : ms((p_to - p_from) / 1000.0);
}

} // namespace

bool XREFrameTimer::start(int64_t p_max_frames) {
	Recorder &r = recorder();
	ERR_FAIL_COND_V_MSG(r.recording, false, "XREFrameTimer is already recording.");
	ERR_FAIL_COND_V(p_max_frames <= 0, false);
	r.frames.clear();
	r.frames.reserve(size_t(p_max_frames));
	r.max_frames = size_t(p_max_frames);
	r.variants.clear();
	return true;
}

void XREFrameTimer::begin_segment(int64_t p_segment, const String &p_variant, const RID &p_xr_viewport, const TypedArray<RID> &p_desktop_viewports) {
	Recorder &r = recorder();
	ERR_FAIL_COND_MSG(r.max_frames == 0, "Call XREFrameTimer.start() first.");
	ERR_FAIL_COND(p_segment < 0);

	RenderingServer *rs = RenderingServer::get_singleton();
	r.xr_viewport = p_xr_viewport;
	rs->viewport_set_measure_render_time(p_xr_viewport, true);
	r.desktop_viewports.clear();
	for (int64_t i = 0; i < p_desktop_viewports.size(); i++) {
		const RID viewport = p_desktop_viewports[i];
		r.desktop_viewports.push_back(viewport);
		rs->viewport_set_measure_render_time(viewport, true);
	}
	if (r.variants.size() <= size_t(p_segment)) {
		r.variants.resize(size_t(p_segment) + 1);
	}
	r.variants[size_t(p_segment)] = p_variant.utf8().get_data();

	r.segment = int(p_segment);
	r.pending_wait_begin_usec = 0;
	r.recording = true;
}

void XREFrameTimer::end_segment() {
	recorder().recording = false;
}

int64_t XREFrameTimer::stop() {
	Recorder &r = recorder();
	r.recording = false;
	return int64_t(r.frames.size());
}

bool XREFrameTimer::is_recording() {
	return recorder().recording;
}

void XREFrameTimer::on_wait_begin(uint64_t p_usec, bool p_closed_frame) {
	Recorder &r = recorder();
	if (!r.recording) {
		return;
	}
	if (Frame *frame = r.current()) {
		frame->next_wait_begin_usec = p_usec;
	}
	r.pending_wait_begin_usec = p_usec;
	r.pending_closed = p_closed_frame;
}

void XREFrameTimer::on_wait_end(uint64_t p_usec, int p_session_state, bool p_can_render) {
	Recorder &r = recorder();
	// No start time if recording began between this wait's start and its return.
	if (!r.recording || r.pending_wait_begin_usec == 0) {
		return;
	}
	if (r.frames.size() >= r.max_frames) {
		r.recording = false;
		return;
	}

	RenderingServer *rs = RenderingServer::get_singleton();
	double gpu_desktop_ms = 0.0;
	for (const RID &viewport : r.desktop_viewports) {
		gpu_desktop_ms += rs->viewport_get_measured_render_time_gpu(viewport);
	}
	r.frames.push_back({
			r.segment,
			r.pending_wait_begin_usec,
			p_usec,
			0,
			0,
			0,
			0,
			0,
			rs->viewport_get_measured_render_time_gpu(r.xr_viewport),
			gpu_desktop_ms,
			p_session_state,
			p_can_render,
			r.pending_closed,
	});
	r.pending_wait_begin_usec = 0;
}

void XREFrameTimer::on_frame_begun(uint64_t p_usec) {
	if (Frame *frame = recorder().recording ? recorder().current() : nullptr) {
		frame->begun_usec = p_usec;
	}
}

void XREFrameTimer::on_xr_swapchain_ready(uint64_t p_usec) {
	if (Frame *frame = recorder().recording ? recorder().current() : nullptr) {
		frame->swapchain_ready_usec = p_usec;
	}
}

void XREFrameTimer::on_xr_recorded(uint64_t p_usec) {
	if (Frame *frame = recorder().recording ? recorder().current() : nullptr) {
		frame->recorded_usec = p_usec;
	}
}

void XREFrameTimer::on_frame_end(uint64_t p_usec) {
	if (Frame *frame = recorder().recording ? recorder().current() : nullptr) {
		frame->end_usec = p_usec;
	}
}

Error XREFrameTimer::save_csv(const String &p_path) {
	const Recorder &r = recorder();
	ERR_FAIL_COND_V_MSG(r.recording, ERR_BUSY, "Stop XREFrameTimer before saving.");

	Ref<FileAccess> file = FileAccess::open(p_path, FileAccess::WRITE);
	if (file.is_null()) {
		return FileAccess::get_open_error();
	}
	file->store_line("segment,variant,frame,t_ms,interval_ms,wait_ms,cpu_ms,process_ms,swapchain_ms,xr_record_ms,submit_ms,after_ms,"
					 "gpu_xr_ms,gpu_desktop_ms,gpu_ms,session_state,can_render,closed_before_wait");

	const std::vector<Frame> &frames = r.frames;
	size_t segment_start = 0;
	for (size_t k = 0; k < frames.size(); k++) {
		const Frame &frame = frames[k];
		// The first frame of a segment has no interval; one without the next wait has no end of its work.
		if (k == 0 || frames[k - 1].segment != frame.segment) {
			segment_start = k;
			continue;
		}
		if (frame.next_wait_begin_usec == 0) {
			continue;
		}
		const String variant = size_t(frame.segment) < r.variants.size() ? String::utf8(r.variants[size_t(frame.segment)].c_str()) : String();
		file->store_line(String::num_int64(frame.segment) + "," + variant + "," + String::num_int64(int64_t(k - segment_start)) + "," +
				ms((frame.wait_end_usec - frames[segment_start].wait_end_usec) / 1000.0) + "," +
				span(frames[k - 1].wait_end_usec, frame.wait_end_usec) + "," +
				span(frame.wait_begin_usec, frame.wait_end_usec) + "," +
				span(frame.wait_end_usec, frame.next_wait_begin_usec) + "," +
				span(frame.wait_end_usec, frame.begun_usec) + "," +
				span(frame.begun_usec, frame.swapchain_ready_usec) + "," +
				span(frame.swapchain_ready_usec, frame.recorded_usec) + "," +
				span(frame.recorded_usec, frame.end_usec) + "," +
				span(frame.end_usec, frame.next_wait_begin_usec) + "," +
				ms(frame.gpu_xr_ms) + "," + ms(frame.gpu_desktop_ms) + "," + ms(frame.gpu_xr_ms + frame.gpu_desktop_ms) + "," +
				String::num_int64(frame.session_state) + "," + (frame.can_render ? "1" : "0") + "," + (frame.closed_before_wait ? "1" : "0"));
	}
	return file->get_error();
}

void XREFrameTimer::_bind_methods() {
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("start", "max_frames"), &XREFrameTimer::start);
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("begin_segment", "segment", "variant", "xr_viewport", "desktop_viewports"), &XREFrameTimer::begin_segment);
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("end_segment"), &XREFrameTimer::end_segment);
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("stop"), &XREFrameTimer::stop);
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("is_recording"), &XREFrameTimer::is_recording);
	ClassDB::bind_static_method("XREFrameTimer", D_METHOD("save_csv", "path"), &XREFrameTimer::save_csv);
}

} // namespace xre
