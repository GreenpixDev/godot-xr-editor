@tool
class_name XRETabIcons
extends RefCounted
## Icons of the panels in the headset (docs/decisions.md, D-041, D-042): one
## per tab, as an app has in the Meta Horizon OS launcher, and small glyphs for
## a window's control bar and the launcher's dock. Drawn from SVG at the size
## asked for, so that they stay sharp in the headset at any editor scale; the
## editor's own icons are 16 pixels and two tabs share one of them.
##
## A tab icon is a rounded tile with a top-to-bottom gradient and a white
## glyph, as Meta's app icons are; a glyph alone is white on nothing, for
## buttons.

## Tab icons, by [method XREPanelTab.get_symbol]: the gradient's top and
## bottom colors, and the glyph.
const TABS: Dictionary[StringName, Array] = {
	# Things to add to the scene (D-045): a cube.
	&"objects": ["#ff8ad8", "#c94ab0", """<g fill="none" stroke="#fff" stroke-width="8" stroke-linejoin="round">
<path d="M64 24L102 45V87L64 108L26 87V45Z"/><path d="M26 45L64 66L102 45M64 66V108"/></g>"""],
	&"scene": ["#6d97ff", "#3d63e6", """<g fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round"
stroke-linejoin="round"><circle cx="38" cy="36" r="10"/><path d="M38 46V92M38 64H66M38 92H66"/>
<rect x="68" y="54" width="28" height="20" rx="5"/><rect x="68" y="82" width="28" height="20" rx="5"/></g>"""],
	&"inspector": ["#5fd39b", "#28976a", """<g stroke="#fff" stroke-width="8" stroke-linecap="round">
<path d="M28 40H100M28 64H100M28 88H100"/></g><g fill="#fff"><circle cx="76" cy="40" r="11"/>
<circle cx="48" cy="64" r="11"/><circle cx="84" cy="88" r="11"/></g>"""],
	&"signals": ["#ffbf4d", "#e58a1f", """<circle cx="40" cy="88" r="9" fill="#fff"/>
<g fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round"><path d="M40 62A26 26 0 0 1 66 88"/>
<path d="M40 38A50 50 0 0 1 90 88"/></g>"""],
	&"files": ["#a58bff", "#7350e0", """<path d="M26 44Q26 34 36 34H54L62 44H92Q102 44 102 54V86Q102 96 92 96H36Q26
96 26 86Z" fill="none" stroke="#fff" stroke-width="8" stroke-linejoin="round"/>
<path d="M26 56H102" stroke="#fff" stroke-width="8"/>"""],
	&"blueprints": ["#4fd0e8", "#1f8fb5", """<g fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round"
stroke-linejoin="round"><rect x="20" y="34" width="34" height="28" rx="6"/><rect x="74" y="66" width="34"
height="28" rx="6"/><path d="M54 48C70 48 58 80 74 80"/></g>"""],
	# A block's parameters: the inspector's sliders in the Blueprints' colors (D-044).
	&"parameters": ["#4fd0e8", "#1f8fb5", """<g stroke="#fff" stroke-width="8" stroke-linecap="round">
<path d="M28 40H100M28 64H100M28 88H100"/></g><g fill="#fff"><circle cx="76" cy="40" r="11"/>
<circle cx="48" cy="64" r="11"/><circle cx="84" cy="88" r="11"/></g>"""],
	# Adding a block to the graph: a plus in the Blueprints' colors (D-044).
	&"add_block": ["#4fd0e8", "#1f8fb5", """<path d="M64 34V94M34 64H94" stroke="#fff" stroke-width="10"
stroke-linecap="round"/>"""],
	# Ready values for a block's sockets (D-052): tokens in a tray.
	&"tokens": ["#4fd0e8", "#1f8fb5", """<g fill="none" stroke="#fff" stroke-width="8"><rect x="22" y="30" width="38" height="24" rx="12"/>
<rect x="68" y="30" width="38" height="24" rx="12"/><rect x="22" y="74" width="38" height="24" rx="12"/></g>
<rect x="68" y="74" width="38" height="24" rx="12" fill="#fff"/>"""],
	&"settings": ["#9aa3b2", "#5c6472", """<g fill="none" stroke="#fff" stroke-linecap="round">
<circle cx="64" cy="64" r="24" stroke-width="8"/><circle cx="64" cy="64" r="8" stroke-width="7"/>
<path stroke-width="11" d="M92 64H100M36 64H28M64 36V28M64 92V100M83.8 44.2L89.5 38.5M44.2 83.8L38.5 89.5
M83.8 83.8L89.5 89.5M44.2 44.2L38.5 38.5"/></g>"""],
	&"debug": ["#ff7a85", "#d93a4f", """<path d="M20 68H42L52 44L66 92L78 56L86 68H108" fill="none" stroke="#fff"
stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>"""],
	# The launcher's Playtest tile (D-082): a play triangle, rounded as the other glyphs.
	&"playtest": ["#7be07b", "#2f9e4a", """<path d="M50 36Q44 32 44 40V88Q44 96 50 92L90 68Q96 64 90 60Z" fill="#fff"
stroke="#fff" stroke-width="6" stroke-linejoin="round"/>"""],
}
## Glyphs for buttons: the launcher's library, a window, a pin, close; the
## object's badge's Blueprint, add a block and delete (D-085).
const GLYPHS: Dictionary[StringName, String] = {
	&"blueprint": """<g fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round">
<rect x="14" y="28" width="40" height="32" rx="8"/><rect x="74" y="68" width="40" height="32" rx="8"/>
<path d="M54 44C72 44 56 84 74 84"/></g>""",
	&"plus": """<path d="M64 28V100M28 64H100" stroke="#fff" stroke-width="11" stroke-linecap="round"/>""",
	&"trash": """<g fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round">
<path d="M22 36H106M50 36V24H78V36M34 36L40 106H88L94 36M56 56V86M72 56V86"/></g>""",
	&"library": """<g fill="#fff"><circle cx="34" cy="34" r="10"/><circle cx="64" cy="34" r="10"/>
<circle cx="94" cy="34" r="10"/><circle cx="34" cy="64" r="10"/><circle cx="64" cy="64" r="10"/>
<circle cx="94" cy="64" r="10"/><circle cx="34" cy="94" r="10"/><circle cx="64" cy="94" r="10"/>
<circle cx="94" cy="94" r="10"/></g>""",
	&"window": """<g fill="none" stroke="#fff" stroke-width="9" stroke-linejoin="round">
<rect x="18" y="26" width="92" height="76" rx="12"/><path d="M18 48H110"/></g>""",
	&"pin": """<g fill="none" stroke="#fff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round">
<path d="M46 18H82M54 18V50L36 70H92L74 50V18M64 70V110"/></g>""",
	&"close": """<path d="M34 34L94 94M94 34L34 94" stroke="#fff" stroke-width="11" stroke-linecap="round"/>""",
}

static var _cache: Dictionary[String, Texture2D] = {}


## The icon of the tab with symbol [param symbol], [param size] pixels across,
## or null if there is none.
static func tab(symbol: StringName, size: int) -> Texture2D:
	if not TABS.has(symbol):
		return null
	var icon := TABS[symbol]
	var svg := """<defs><linearGradient id="fill" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="%s"/>
<stop offset="1" stop-color="%s"/></linearGradient></defs><rect x="4" y="4" width="120" height="120" rx="30"
fill="url(#fill)"/>%s""" % [icon[0], icon[1], icon[2]]
	return _texture("tab:" + symbol, svg, size)


## The white glyph [param glyph_name], [param size] pixels across, or null.
static func glyph(glyph_name: StringName, size: int) -> Texture2D:
	if not GLYPHS.has(glyph_name):
		return null
	return _texture("glyph:" + glyph_name, GLYPHS[glyph_name], size)


static func _texture(icon_name: String, body: String, size: int) -> Texture2D:
	if size <= 0:
		return null
	var key := "%s@%d" % [icon_name, size]
	if _cache.has(key):
		return _cache[key]
	var image := Image.new()
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">%s</svg>' % body
	if image.load_svg_from_string(svg, size / 128.0) != OK:
		return null
	image.generate_mipmaps()
	var texture := ImageTexture.create_from_image(image)
	_cache[key] = texture
	return texture
