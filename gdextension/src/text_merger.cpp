#include "text_merger.h"

#include <godot_cpp/classes/base_material3d.hpp>
#include <godot_cpp/classes/font.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/classes/text_server.hpp>
#include <godot_cpp/classes/text_server_manager.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/templates/hashfuncs.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/rect2.hpp>
#include <godot_cpp/variant/vector2i.hpp>

using namespace godot;

namespace xre {

namespace {
Ref<TextServer> text_server() {
	return TextServerManager::get_singleton()->get_primary_interface();
}
} // namespace

uint32_t XRETextMerger::KeyHasher::hash(const Key &p_key) {
	uint32_t h = hash_murmur3_one_64(p_key.texture);
	h = hash_murmur3_one_32(uint32_t(p_key.priority), h);
	h = hash_murmur3_one_32(uint32_t(p_key.outline), h);
	h = hash_murmur3_one_32((p_key.no_depth ? 1u : 0u) | (p_key.double_sided ? 2u : 0u), h);
	return hash_fmix32(h);
}

XRETextMerger::~XRETextMerger() {
	if (shaped.is_valid()) {
		Ref<TextServer> server = text_server();
		if (server.is_valid()) { server->free_rid(shaped); }
	}
}

void XRETextMerger::_bind_methods() {
	ClassDB::bind_method(D_METHOD("merge", "target", "labels", "places", "seen", "count"), &XRETextMerger::merge);
	ClassDB::bind_method(D_METHOD("get_surface_priority", "surface"), &XRETextMerger::get_surface_priority);
	ClassDB::bind_method(D_METHOD("clear_cache"), &XRETextMerger::clear_cache);
}

int XRETextMerger::merge(const Ref<ArrayMesh> &p_target, const Array &p_labels, const Array &p_places, const PackedFloat32Array &p_seen, int p_count) {
	ERR_FAIL_COND_V(p_target.is_null(), 0);
	ERR_FAIL_COND_V(p_count < 0 || p_count > p_labels.size() || p_count > p_places.size() || p_count > p_seen.size(), 0);
	surfaces.clear();
	surface_of.clear();
	for (int i = 0; i < p_count; i++) {
		const Label3D *label = Object::cast_to<Label3D>(p_labels[i]);
		if (label == nullptr) { continue; }
		lay(label, p_places[i], p_seen[i]);
	}
	p_target->clear_surfaces();
	priorities.clear();
	for (Surface &surface : surfaces) {
		if (surface.quads == 0) { continue; }
		Array arrays;
		arrays.resize(Mesh::ARRAY_MAX);
		arrays[Mesh::ARRAY_VERTEX] = surface.vertices;
		arrays[Mesh::ARRAY_NORMAL] = surface.normals;
		arrays[Mesh::ARRAY_COLOR] = surface.colors;
		arrays[Mesh::ARRAY_TEX_UV] = surface.uvs;
		arrays[Mesh::ARRAY_INDEX] = surface.indices;
		p_target->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays);
		p_target->surface_set_material(p_target->get_surface_count() - 1, material_of(surface));
		priorities.push_back(surface.key.priority);
	}
	return p_target->get_surface_count();
}

int XRETextMerger::get_surface_priority(int p_surface) const {
	ERR_FAIL_INDEX_V(p_surface, int(priorities.size()), 0);
	return priorities[p_surface];
}

void XRETextMerger::clear_cache() {
	materials.clear();
}

// Label3D::_shape, for a label with no billboard, no structured text of its own parser and no fill.
void XRETextMerger::lay(const Label3D *p_label, const Transform3D &p_place, double p_seen) {
	Ref<TextServer> server = text_server();
	ERR_FAIL_COND(server.is_null());
	Ref<Font> font = p_label->get_font();
	if (font.is_null()) { return; }
	if (!shaped.is_valid()) { shaped = server->create_shaped_text(); }
	server->shaped_text_clear(shaped);
	server->shaped_text_set_direction(shaped, p_label->get_text_direction());
	const String language = p_label->get_language();
	String text = p_label->get_text();
	if (p_label->is_uppercase()) { text = server->string_to_upper(text, language); }
	server->shaped_text_add_string(shaped, text, font->get_rids(), p_label->get_font_size(), font->get_opentype_features(), language);
	server->shaped_text_set_bidi_override(shaped, server->parse_structured_text(p_label->get_structured_text_bidi_override(), p_label->get_structured_text_bidi_override_options(), text));

	BitField<TextServer::LineBreakFlag> flags = TextServer::BREAK_MANDATORY;
	switch (p_label->get_autowrap_mode()) {
		case TextServer::AUTOWRAP_WORD_SMART:
			flags = TextServer::BREAK_WORD_BOUND | TextServer::BREAK_ADAPTIVE | TextServer::BREAK_MANDATORY;
			break;
		case TextServer::AUTOWRAP_WORD:
			flags = TextServer::BREAK_WORD_BOUND | TextServer::BREAK_MANDATORY;
			break;
		case TextServer::AUTOWRAP_ARBITRARY:
			flags = TextServer::BREAK_GRAPHEME_BOUND | TextServer::BREAK_MANDATORY;
			break;
		default:
			break;
	}
	flags = int64_t(flags) | int64_t(p_label->get_autowrap_trim_flags());
	const PackedInt32Array breaks = server->shaped_text_get_line_breaks(shaped, p_label->get_width(), 0, flags);
	LocalVector<RID> lines;
	for (int64_t i = 0; i + 1 < breaks.size(); i += 2) { lines.push_back(server->shaped_text_substr(shaped, breaks[i], breaks[i + 1] - breaks[i])); }

	const double pixel_size = p_label->get_pixel_size();
	const double line_spacing = p_label->get_line_spacing();
	const Vector2 label_offset = p_label->get_offset();
	float total = 0.0f;
	for (const RID &line : lines) { total += float((server->shaped_text_get_size(line).y + line_spacing) * pixel_size); }
	float begin = 0.0f;
	switch (p_label->get_vertical_alignment()) {
		case VERTICAL_ALIGNMENT_CENTER:
			begin = float((total - line_spacing * pixel_size) / 2.0);
			break;
		case VERTICAL_ALIGNMENT_BOTTOM:
			begin = float(total - line_spacing * pixel_size);
			break;
		default:
			break;
	}
	Color color = p_label->get_modulate();
	color.a *= float(p_seen);
	Color outline_color = p_label->get_outline_modulate();
	const bool outlined = outline_color.a != 0.0f && p_label->get_outline_size() > 0;
	outline_color.a *= float(p_seen);
	Vector2 offset(0, float(begin + label_offset.y * pixel_size));
	for (const RID &line : lines) {
		const TypedArray<Dictionary> glyphs = server->shaped_text_get_glyphs(line);
		const float width = float(server->shaped_text_get_width(line) * pixel_size);
		switch (p_label->get_horizontal_alignment()) {
			case HORIZONTAL_ALIGNMENT_LEFT:
				offset.x = 0.0f;
				break;
			case HORIZONTAL_ALIGNMENT_RIGHT:
				offset.x = -width;
				break;
			default:
				offset.x = -width / 2.0f;
				break;
		}
		offset.x += float(label_offset.x * pixel_size);
		offset.y -= float(server->shaped_text_get_ascent(line) * pixel_size);
		if (outlined) {
			Vector2 outline_offset = offset;
			for (int64_t j = 0; j < glyphs.size(); j++) { glyph(glyphs[j], outline_offset, outline_color, p_label->get_outline_render_priority(), p_label->get_outline_size(), p_label, p_place); }
		}
		for (int64_t j = 0; j < glyphs.size(); j++) { glyph(glyphs[j], offset, color, p_label->get_render_priority(), 0, p_label, p_place); }
		offset.y -= float((server->shaped_text_get_descent(line) + line_spacing) * pixel_size);
	}
	for (const RID &line : lines) { server->free_rid(line); }
}

// Label3D::_generate_glyph_surfaces, with alpha cut off (no z shift).
void XRETextMerger::glyph(const Dictionary &p_glyph, Vector2 &r_offset, const Color &p_color, int p_priority, int p_outline, const Label3D *p_label, const Transform3D &p_place) {
	Ref<TextServer> server = text_server();
	const float pixel_size = float(p_label->get_pixel_size());
	const int64_t index = p_glyph["index"];
	const float advance = float(double(p_glyph["advance"]));
	const int64_t repeat = p_glyph["repeat"];
	if (index == 0) {
		r_offset.x += advance * pixel_size * float(repeat);
		return;
	}
	const RID font_rid = p_glyph["font_rid"];
	const int64_t font_size = p_glyph["font_size"];
	if (!font_rid.is_valid()) {
		r_offset.x += advance * pixel_size * float(repeat);
		return;
	}
	const Vector2i size(int32_t(font_size), p_outline);
	const RID texture = server->font_get_glyph_texture_rid(font_rid, size, index);
	if (!texture.is_valid()) {
		r_offset.x += advance * pixel_size * float(repeat);
		return;
	}
	const Vector2 shift = p_glyph["offset"];
	const Vector2 glyph_offset = (server->font_get_glyph_offset(font_rid, size, index) + shift) * pixel_size;
	const Vector2 glyph_size = server->font_get_glyph_size(font_rid, size, index) * pixel_size;
	const Rect2 uv = server->font_get_glyph_uv_rect(font_rid, size, index);
	const Vector2 texture_size = server->font_get_glyph_texture_size(font_rid, size, index);
	if (uv.size.x <= 2 || uv.size.y <= 2) {
		r_offset.x += advance * pixel_size * float(repeat);
		return;
	}
	Key key;
	key.texture = texture.get_id();
	key.priority = p_priority;
	key.outline = p_outline;
	key.no_depth = p_label->get_draw_flag(Label3D::FLAG_DISABLE_DEPTH_TEST);
	key.double_sided = p_label->get_draw_flag(Label3D::FLAG_DOUBLE_SIDED);
	int *known = surface_of.getptr(key);
	if (known == nullptr) {
		Surface surface;
		surface.key = key;
		surface.texture = texture;
		surface.texture_size = texture_size;
		surface.pixel_range = server->font_is_multichannel_signed_distance_field(font_rid) ? server->font_get_msdf_pixel_range(font_rid) : 0;
		surfaces.push_back(surface);
		known = &surface_of.insert(key, int(surfaces.size()) - 1)->value;
	}
	Surface &surface = surfaces[*known];
	const Vector3 normal = p_place.basis.xform(Vector3(0, 0, 1)).normalized();
	for (int64_t j = 0; j < repeat; j++) {
		const int32_t base = int32_t(surface.quads * 4);
		const Vector3 corners[4] = {
			Vector3(r_offset.x + glyph_offset.x, r_offset.y - glyph_offset.y, 0),
			Vector3(r_offset.x + glyph_offset.x + glyph_size.x, r_offset.y - glyph_offset.y, 0),
			Vector3(r_offset.x + glyph_offset.x + glyph_size.x, r_offset.y - glyph_offset.y - glyph_size.y, 0),
			Vector3(r_offset.x + glyph_offset.x, r_offset.y - glyph_offset.y - glyph_size.y, 0),
		};
		const Vector2 uvs[4] = {
			Vector2(uv.position.x / texture_size.x, uv.position.y / texture_size.y),
			Vector2((uv.position.x + uv.size.x) / texture_size.x, uv.position.y / texture_size.y),
			Vector2((uv.position.x + uv.size.x) / texture_size.x, (uv.position.y + uv.size.y) / texture_size.y),
			Vector2(uv.position.x / texture_size.x, (uv.position.y + uv.size.y) / texture_size.y),
		};
		for (int i = 0; i < 4; i++) {
			surface.vertices.push_back(p_place.xform(corners[i]));
			surface.normals.push_back(normal);
			surface.colors.push_back(p_color);
			surface.uvs.push_back(uvs[i]);
		}
		const int32_t order[6] = { 0, 1, 2, 0, 2, 3 };
		for (int i = 0; i < 6; i++) { surface.indices.push_back(base + order[i]); }
		surface.quads++;
		r_offset.x += advance * pixel_size;
	}
}

// As Label3D's surface material: BaseMaterial3D::get_material_for_2d unshaded, alpha blended, with Label3D's params.
Ref<StandardMaterial3D> XRETextMerger::material_of(const Surface &p_surface) {
	if (const Ref<StandardMaterial3D> *known = materials.getptr(p_surface.key)) { return *known; }
	Ref<StandardMaterial3D> material;
	material.instantiate();
	material->set_shading_mode(BaseMaterial3D::SHADING_MODE_UNSHADED);
	material->set_transparency(BaseMaterial3D::TRANSPARENCY_ALPHA);
	material->set_cull_mode(p_surface.key.double_sided ? BaseMaterial3D::CULL_DISABLED : BaseMaterial3D::CULL_BACK);
	material->set_flag(BaseMaterial3D::FLAG_SRGB_VERTEX_COLOR, true);
	material->set_flag(BaseMaterial3D::FLAG_ALBEDO_FROM_VERTEX_COLOR, true);
	material->set_flag(BaseMaterial3D::FLAG_ALBEDO_TEXTURE_MSDF, p_surface.pixel_range > 0);
	material->set_flag(BaseMaterial3D::FLAG_DISABLE_DEPTH_TEST, p_surface.key.no_depth);
	material->set_texture_filter(BaseMaterial3D::TEXTURE_FILTER_LINEAR_WITH_MIPMAPS);
	material->set_render_priority(p_surface.key.priority);
	if (p_surface.pixel_range > 0) {
		material->set_msdf_pixel_range(float(p_surface.pixel_range));
		material->set_msdf_outline_size(float(p_surface.key.outline));
	}
	// The atlas page is the text server's texture, not a resource: given to the server's material by its RID.
	RenderingServer *rendering = RenderingServer::get_singleton();
	rendering->material_set_param(material->get_rid(), "texture_albedo", p_surface.texture);
	rendering->material_set_param(material->get_rid(), "albedo_texture_size", Vector2i(p_surface.texture_size));
	materials.insert(p_surface.key, material);
	return material;
}

} // namespace xre
