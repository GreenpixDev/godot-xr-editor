#!/usr/bin/env python3
"""Frame time report for the XR Editor spike (docs/plan.md, step 2).

Reads the per-frame CSV that XREFrameBenchmark writes (frametime_<stamp>.csv
with segment and variant columns; the first run of 2026-10-05 wrote one file
per segment, frametime_<stamp>_<n>_<variant>.csv, which is read as well) and
the run's *_meta.json, prints a Markdown summary and writes it next to the CSV
together with two SVG charts: a histogram of frame times per variant and frame
time over the run. Standard library only.

Definitions (also in docs/decisions.md):
- valid frame: session VISIBLE or FOCUSED and the runtime asked to render it;
- frame time: max(cpu_ms, gpu_ms), i.e. the frame fits the budget only if both
  the main thread and the GPU do;
- budget: one display period at the target rate, 1000 / 90 ms;
- missed frame: interval between two xrWaitFrame returns > 1.5 display periods
  (the runtime showed an older frame or halved the rate, e.g. ASW at 45 Hz);
- threshold (docs/plan.md): at least 95 % of valid frames within the budget.

Usage: py benchmarks/frametime_report.py benchmarks/results/frametime_<stamp>.csv
"""

from __future__ import annotations

import csv
import json
import math
import re
import statistics
import sys
from dataclasses import dataclass, field
from pathlib import Path

TARGET_HZ = 90.0
BUDGET_MS = 1000.0 / TARGET_HZ
THRESHOLD = 0.95
VALID_STATES = {4, 5}  # XR_SESSION_STATE_VISIBLE, XR_SESSION_STATE_FOCUSED
VARIANT_LABELS = {
    "ui_visible": "2D-интерфейс открыт",
    "ui_hidden": "2D-интерфейс скрыт",
}
VARIANT_COLORS = {"ui_visible": "#d9480f", "ui_hidden": "#1971c2"}
NAME_PATTERN = re.compile(r"frametime_(?P<stamp>[0-9T-]+)(?:_(?P<segment>\d+)_(?P<variant>ui_[a-z]+))?\.csv$")
# Main-thread phases of a frame (XREFrameTimer), in order; absent in the first run's files.
PHASES = {
    "process_ms": "логика редактора",
    "swapchain_ms": "до кадра свопчейна",
    "xr_record_ms": "запись XR-вида",
    "submit_ms": "до xrEndFrame",
    "after_ms": "после xrEndFrame",
}

HIST_MAX_MS = 25.0
HIST_BIN_MS = 0.5
SERIES_MAX_MS = 30.0


@dataclass
class Frames:
    """Valid frames of one segment or of all segments of a variant."""

    variant: str
    segment: int = 0
    total: int = 0
    closed: int = 0
    t_s: list[float] = field(default_factory=list)
    frame_ms: list[float] = field(default_factory=list)
    cpu_ms: list[float] = field(default_factory=list)
    gpu_ms: list[float] = field(default_factory=list)
    interval_ms: list[float] = field(default_factory=list)
    phases: dict[str, list[float]] = field(default_factory=dict)

    @property
    def label(self) -> str:
        return VARIANT_LABELS.get(self.variant, self.variant)

    @property
    def valid(self) -> int:
        return len(self.frame_ms)

    def share_within(self, budget_ms: float) -> float:
        if not self.frame_ms:
            return math.nan
        return sum(1 for value in self.frame_ms if value <= budget_ms) / len(self.frame_ms)

    def missed(self, period_ms: float) -> int:
        return sum(1 for value in self.interval_ms if value > 1.5 * period_ms)

    def extend(self, other: Frames) -> None:
        self.total += other.total
        self.closed += other.closed
        self.t_s += other.t_s
        self.frame_ms += other.frame_ms
        self.cpu_ms += other.cpu_ms
        self.gpu_ms += other.gpu_ms
        self.interval_ms += other.interval_ms
        for phase, values in other.phases.items():
            self.phases.setdefault(phase, []).extend(values)


def load_segments(path: Path) -> list[Frames]:
    """Segments of one CSV: by its segment column, or one segment named after the file."""
    match = NAME_PATTERN.search(path.name)
    segments: dict[int, Frames] = {}
    with path.open(newline="", encoding="utf-8") as file:
        for row in csv.DictReader(file):
            if "segment" in row:
                number, variant = int(row["segment"]), row["variant"]
            else:
                number = int(match["segment"] or 0) if match else 0
                variant = match["variant"] if match and match["variant"] else path.stem
            frames = segments.setdefault(number, Frames(variant, number))
            frames.total += 1
            if not row["cpu_ms"] or int(row["session_state"]) not in VALID_STATES or row["can_render"] != "1":
                continue
            cpu = float(row["cpu_ms"])
            gpu = float(row["gpu_ms"])
            frames.t_s.append(float(row["t_ms"]) / 1000.0)
            frames.cpu_ms.append(cpu)
            frames.gpu_ms.append(gpu)
            frames.frame_ms.append(max(cpu, gpu))
            frames.interval_ms.append(float(row["interval_ms"]))
            frames.closed += row["closed_before_wait"] == "1"
            for phase in PHASES:
                if row.get(phase):
                    frames.phases.setdefault(phase, []).append(float(row[phase]))
    return list(segments.values())


def percentile(values: list[float], fraction: float) -> float:
    """Linear interpolation between closest ranks."""
    if not values:
        return math.nan
    ordered = sorted(values)
    position = (len(ordered) - 1) * fraction
    low = math.floor(position)
    high = math.ceil(position)
    return ordered[low] + (ordered[high] - ordered[low]) * (position - low)


def ru(value: float, digits: int = 2) -> str:
    """Number in Russian notation (decimal comma)."""
    if value is None or math.isnan(value):
        return "—"
    return f"{value:.{digits}f}".replace(".", ",")


def segments_line(meta: dict) -> str:
    """How the run was split: fixed segments, or (mode "sessions") one per stretch the editor had the headset."""
    if meta.get("mode") == "sessions":
        return "- Сегменты: каждый отрезок, пока шлем у редактора (до игры и после каждого возврата), по метаданным длительность не задана"
    return (f"- Сегменты: {', '.join(meta.get('segments', []))}, по {ru(float(meta.get('record_sec', math.nan)), 0)} с "
            f"после прогрева {ru(float(meta.get('warmup_sec', math.nan)), 0)} с")


def report(variants: list[Frames], segments: list[Frames], meta: dict, period_ms: float) -> str:
    lines = [f"# Время кадра редактора в VR — {meta.get('stamp', '')}", ""]
    lines += [
        f"- Godot: {meta.get('godot', '?')}, коммит `{str(meta.get('git_head', '?'))[:12]}`",
        f"- OpenXR: {meta.get('openxr_runtime', '?')}, {meta.get('openxr_system', '?')}, "
        f"частота дисплея {ru(float(meta.get('display_refresh_rate_hz', math.nan)), 1)} Гц, "
        f"рендер {meta.get('render_target_size', '?')} на глаз",
        f"- GPU: {meta.get('gpu', '?')}, CPU: {str(meta.get('cpu', '?')).strip()}",
        f"- Сцена: `{meta.get('scene', '?')}` ({meta.get('scene_nodes', '?')} нод), "
        f"3D-вьюпорт редактора виден: {meta.get('editor_3d_viewport_visible', '?')}",
        f"- Панель Output: группировка дубликатов {meta.get('editor_log_collapse', 'не записано')}, "
        f"лимит строк {meta.get('editor_log_max_lines', 'не записан')}",
        segments_line(meta),
        "",
        f"Время кадра = max(CPU, GPU); бюджет {ru(BUDGET_MS)} мс ({ru(TARGET_HZ, 0)} Гц); "
        f"порог плана — не меньше {ru(THRESHOLD * 100, 0)} % валидных кадров в бюджете.",
        "",
    ]
    if not math.isclose(float(meta.get("display_refresh_rate_hz", TARGET_HZ)), TARGET_HZ, abs_tol=0.5):
        lines += [f"**Внимание:** дисплей работал не на {ru(TARGET_HZ, 0)} Гц — интервалы и пропуски относятся "
                  "к другой частоте; доли по CPU и GPU от неё почти не зависят.", ""]

    header = ("| Вариант | Кадров (валидных) | В бюджете | p50 | p95 | p99 | max | CPU p95 | GPU p95 "
              "| Интервал p50 | Пропущено | Дорисовано | Порог |")
    lines += ["## По вариантам", "", header, "|" + "---|" * (header.count("|") - 1)]
    for frames in variants:
        share = frames.share_within(BUDGET_MS)
        verdict = "выполнен" if share >= THRESHOLD else "не выполнен"
        lines.append(
            f"| {frames.label} | {frames.total} ({frames.valid}) | {ru(share * 100, 1)} % "
            f"| {ru(percentile(frames.frame_ms, 0.5))} | {ru(percentile(frames.frame_ms, 0.95))} "
            f"| {ru(percentile(frames.frame_ms, 0.99))} | {ru(max(frames.frame_ms, default=math.nan))} "
            f"| {ru(percentile(frames.cpu_ms, 0.95))} | {ru(percentile(frames.gpu_ms, 0.95))} "
            f"| {ru(percentile(frames.interval_ms, 0.5))} | {frames.missed(period_ms)} | {frames.closed} | {verdict} |"
        )

    header = "| № | Вариант | Валидных кадров | В бюджете | p95 | CPU p50 | GPU p50 | Интервал p50 | Пропущено |"
    lines += ["", "## По сегментам (порядок записи)", "", header, "|" + "---|" * (header.count("|") - 1)]
    for frames in segments:
        lines.append(
            f"| {frames.segment} | {frames.label} | {frames.valid} | {ru(frames.share_within(BUDGET_MS) * 100, 1)} % "
            f"| {ru(percentile(frames.frame_ms, 0.95))} | {ru(percentile(frames.cpu_ms, 0.5))} "
            f"| {ru(percentile(frames.gpu_ms, 0.5))} | {ru(percentile(frames.interval_ms, 0.5))} | {frames.missed(period_ms)} |"
        )
    if any(frames.phases for frames in segments):
        header = "| № | Вариант | " + " | ".join(PHASES.values()) + " | CPU всего |"
        lines += ["", "## Фазы главного потока по сегментам (медианы)", "", header, "|" + "---|" * (header.count("|") - 1)]
        for frames in segments:
            cells = [ru(percentile(frames.phases.get(phase, []), 0.5)) for phase in PHASES]
            lines.append(f"| {frames.segment} | {frames.label} | " + " | ".join(cells) + f" | {ru(percentile(frames.cpu_ms, 0.5))} |")
    lines += ["", "Времена в миллисекундах. «Пропущено» — интервал между кадрами больше 1,5 периода дисплея "
              "(рантайм показал старый кадр или снизил частоту вдвое); «Дорисовано» — кадры, которые "
              "XREEditorFrameLoop закрыл перед вложенным xrWaitFrame.", ""]
    return "\n".join(lines)


def svg_open(width: int, height: int, title: str) -> list[str]:
    return [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" '
        'font-family="Segoe UI, Arial, sans-serif" font-size="12">',
        f'<rect width="{width}" height="{height}" fill="#ffffff"/>',
        f'<text x="64" y="28" font-size="15" font-weight="600" fill="#212529">{title}</text>',
    ]


def histogram_svg(variants: list[Frames], title: str) -> str:
    width, height = 860, 420
    left, right, top, bottom = 64, 24, 48, 64
    plot_w, plot_h = width - left - right, height - top - bottom
    bins = int(HIST_MAX_MS / HIST_BIN_MS)

    shares: dict[str, list[float]] = {}
    for frames in variants:
        counts = [0] * (bins + 1)  # last bin: everything above HIST_MAX_MS
        for value in frames.frame_ms:
            counts[min(int(value / HIST_BIN_MS), bins)] += 1
        shares[frames.variant] = [100.0 * count / max(frames.valid, 1) for count in counts]
    y_max = max((max(values) for values in shares.values()), default=1.0)
    y_max = max(10.0, math.ceil(y_max / 10.0) * 10.0)

    def x_of(ms: float) -> float:
        return left + plot_w * ms / (HIST_MAX_MS + HIST_BIN_MS)

    def y_of(share: float) -> float:
        return top + plot_h * (1.0 - share / y_max)

    parts = svg_open(width, height, title)
    for tick in range(0, int(y_max) + 1, int(y_max // 5) or 1):
        y = y_of(tick)
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{left + plot_w}" y2="{y:.1f}" stroke="#e9ecef"/>')
        parts.append(f'<text x="{left - 8}" y="{y + 4:.1f}" text-anchor="end" fill="#495057">{tick}</text>')
    for tick in range(0, int(HIST_MAX_MS), 5):
        parts.append(f'<text x="{x_of(tick):.1f}" y="{top + plot_h + 18}" text-anchor="middle" fill="#495057">{tick}</text>')
    parts.append(f'<text x="{x_of(HIST_MAX_MS + HIST_BIN_MS / 2):.1f}" y="{top + plot_h + 18}" text-anchor="middle" '
                 f'fill="#495057">{int(HIST_MAX_MS)}+</text>')
    parts.append(f'<text x="{left + plot_w / 2}" y="{height - 16}" text-anchor="middle" fill="#212529">'
                 'Время кадра max(CPU, GPU), мс</text>')
    parts.append(f'<text transform="translate(18 {top + plot_h / 2}) rotate(-90)" text-anchor="middle" fill="#212529">'
                 'Доля кадров, %</text>')

    for frames in variants:
        color = VARIANT_COLORS.get(frames.variant, "#495057")
        points = [f"{x_of(0):.1f},{y_of(0):.1f}"]
        for index, share in enumerate(shares[frames.variant]):
            x0, x1 = x_of(index * HIST_BIN_MS), x_of((index + 1) * HIST_BIN_MS)
            points += [f"{x0:.1f},{y_of(share):.1f}", f"{x1:.1f},{y_of(share):.1f}"]
        points.append(f"{x_of((bins + 1) * HIST_BIN_MS):.1f},{y_of(0):.1f}")
        parts.append(f'<polygon points="{" ".join(points)}" fill="{color}" fill-opacity="0.18" stroke="{color}" stroke-width="1.5"/>')

    budget_x = x_of(BUDGET_MS)
    parts.append(f'<line x1="{budget_x:.1f}" y1="{top}" x2="{budget_x:.1f}" y2="{top + plot_h}" stroke="#212529" stroke-dasharray="5 4"/>')
    parts.append(f'<text x="{budget_x + 6:.1f}" y="{top + 14}" fill="#212529">бюджет {ru(BUDGET_MS)} мс (90 Гц)</text>')
    parts.append(f'<line x1="{left}" y1="{top + plot_h}" x2="{left + plot_w}" y2="{top + plot_h}" stroke="#868e96"/>')

    legend_y = top + 36
    for frames in variants:
        color = VARIANT_COLORS.get(frames.variant, "#495057")
        x = left + plot_w - 330
        parts.append(f'<rect x="{x}" y="{legend_y - 10}" width="12" height="12" fill="{color}" fill-opacity="0.5" stroke="{color}"/>')
        parts.append(f'<text x="{x + 18}" y="{legend_y}" fill="#212529">{frames.label}: '
                     f'{ru(frames.share_within(BUDGET_MS) * 100, 1)} % в бюджете (n = {frames.valid})</text>')
        legend_y += 20
    parts.append("</svg>")
    return "\n".join(parts)


def timeline_svg(segments: list[Frames], title: str) -> str:
    """Per-second medians of frame time and frame interval, segments side by side."""
    width, height = 860, 380
    left, right, top, bottom = 64, 24, 48, 72
    plot_w, plot_h = width - left - right, height - top - bottom
    durations = [math.ceil(max(frames.t_s, default=0.0)) + 1 for frames in segments]
    total_s = max(sum(durations), 1)

    def x_of(seconds: float) -> float:
        return left + plot_w * seconds / total_s

    def y_of(ms: float) -> float:
        return top + plot_h * (1.0 - min(ms, SERIES_MAX_MS) / SERIES_MAX_MS)

    parts = svg_open(width, height, title)
    for tick in range(0, int(SERIES_MAX_MS) + 1, 5):
        y = y_of(tick)
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{left + plot_w}" y2="{y:.1f}" stroke="#e9ecef"/>')
        parts.append(f'<text x="{left - 8}" y="{y + 4:.1f}" text-anchor="end" fill="#495057">{tick}</text>')

    offset = 0
    for frames, duration in zip(segments, durations):
        color = VARIANT_COLORS.get(frames.variant, "#495057")
        x0, x1 = x_of(offset), x_of(offset + duration)
        parts.append(f'<rect x="{x0:.1f}" y="{top}" width="{x1 - x0:.1f}" height="{plot_h}" fill="{color}" fill-opacity="0.06"/>')
        parts.append(f'<text x="{(x0 + x1) / 2:.1f}" y="{top + plot_h + 18}" text-anchor="middle" fill="#495057">'
                     f'{frames.segment}. {frames.label}</text>')
        by_second: dict[int, tuple[list[float], list[float]]] = {}
        for t, frame, interval in zip(frames.t_s, frames.frame_ms, frames.interval_ms):
            bucket = by_second.setdefault(int(t), ([], []))
            bucket[0].append(frame)
            bucket[1].append(interval)
        for series, style in ((0, f'stroke="{color}" stroke-width="1.8"'), (1, 'stroke="#495057" stroke-width="1.2" stroke-dasharray="3 3"')):
            points = [f"{x_of(offset + second + 0.5):.1f},{y_of(statistics.median(values[series])):.1f}"
                      for second, values in sorted(by_second.items())]
            if points:
                parts.append(f'<polyline points="{" ".join(points)}" fill="none" {style}/>')
        offset += duration

    budget_y = y_of(BUDGET_MS)
    parts.append(f'<line x1="{left}" y1="{budget_y:.1f}" x2="{left + plot_w}" y2="{budget_y:.1f}" stroke="#212529" stroke-dasharray="5 4"/>')
    parts.append(f'<text x="{left + 6}" y="{budget_y - 6:.1f}" fill="#212529">бюджет {ru(BUDGET_MS)} мс</text>')
    parts.append(f'<text transform="translate(18 {top + plot_h / 2}) rotate(-90)" text-anchor="middle" fill="#212529">'
                 'мс (медиана за секунду)</text>')
    parts.append(f'<text x="{left}" y="{height - 16}" fill="#212529">Сплошная линия — время кадра max(CPU, GPU); '
                 'пунктир — интервал между кадрами (22,2 мс = рантайм перешёл на 45 Гц)</text>')
    parts.append("</svg>")
    return "\n".join(parts)


def main(arguments: list[str]) -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    paths = [Path(argument) for argument in arguments if argument.endswith(".csv")]
    if not paths:
        print(__doc__)
        return 1
    segments = sorted((frames for path in paths for frames in load_segments(path)), key=lambda frames: frames.segment)
    match = NAME_PATTERN.search(paths[0].name)
    stamp = match["stamp"] if match else paths[0].stem
    meta_path = paths[0].with_name(f"frametime_{stamp}_meta.json")
    meta = json.loads(meta_path.read_text(encoding="utf-8")) if meta_path.exists() else {}
    meta["stamp"] = stamp
    refresh_hz = float(meta.get("display_refresh_rate_hz") or TARGET_HZ)
    period_ms = 1000.0 / refresh_hz

    variants: dict[str, Frames] = {}
    for frames in segments:
        variants.setdefault(frames.variant, Frames(frames.variant)).extend(frames)
    order = list(VARIANT_LABELS)
    ordered = sorted(variants.values(), key=lambda frames: order.index(frames.variant) if frames.variant in order else len(order))

    text = report(ordered, segments, meta, period_ms)
    print(text)
    base = paths[0].with_name(f"frametime_{stamp}")
    # LF on every platform, as in the repository (.gitattributes).
    base.with_name(base.name + "_report.md").write_text(text, encoding="utf-8", newline="\n")
    base.with_name(base.name + "_histogram.svg").write_text(
        histogram_svg(ordered, f"Время кадра редактора в VR, {stamp}, {ru(refresh_hz, 0)} Гц"), encoding="utf-8", newline="\n")
    base.with_name(base.name + "_timeline.svg").write_text(
        timeline_svg(segments, f"Время кадра и интервал по ходу замера, {stamp}"), encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
