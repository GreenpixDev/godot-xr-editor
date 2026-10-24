@tool
class_name XREBlueprintLinks
extends RefCounted
## Links (D-074): a detail in a port that stands for a variable or a scene
## object, the wire to the variable's box or to the object hidden — fewer
## wires across the graph. A link is only a way of showing a reference the
## graph already has: a Get Variable's variable (an inline one, D-061, shows
## its link in the port it feeds), a block's Target or an event's Source. The
## block keeps the keys whose reference is a link in its field
## [constant FIELD]; the compiler and the 2D editor leave it alone.
##
## A reference is named by a [code]ref[/code]: [code]{"block", "key", "card",
## "port", "kind"}[/code] — the block whose field holds the link, the key
## ([constant VARIABLE] or [constant TARGET]), the card it shows on, the input
## port there (-1 for none) and the kind of socket it is in
## ([constant XREBlueprintCanvas.SOURCE], [constant XREBlueprintCanvas.VARIABLE], -1 for a port).
## Nothing here touches the graph.

## The block field that lists the keys whose reference is a link.
const FIELD := "vr_links"
## A Get or Set Variable's variable, and a block's Target or an event's Source.
const VARIABLE := "variable"
const TARGET := "target"
## The key of a carried link, from the Tokens window or a port.
const KEY := "link"


## Whether the reference of [param key] of [param block] is shown as a link.
static func is_link(block: Dictionary, key: String) -> bool:
	var links: Variant = block.get(FIELD)
	return links is Array and key in (links as Array)


## The field [constant FIELD] of [param block] with the link of [param key]
## on or off: an array of keys, or null for none, as [method XREBlueprintDocument.choose_target] takes it.
static func field_with(block: Dictionary, key: String, on: bool) -> Variant:
	var links: Array = (block[FIELD] as Array).duplicate() if block.get(FIELD) is Array else []
	if on and not key in links: links.append(key)
	elif not on: links.erase(key)
	return links if not links.is_empty() else null


## Turns the link of [param key] on or off in [param entry], a block of a state.
static func set_link(entry: Dictionary, key: String, on: bool) -> void:
	var field: Variant = field_with(entry, key, on)
	if field == null: entry.erase(FIELD)
	else: entry[FIELD] = field


## A ref (see the class) for the link or linkable wire of [param key] held by
## block [param block], shown on card [param card] at input [param port] or in
## socket [param kind].
static func ref(block: int, key: String, card: int, port: int = -1, kind: int = -1) -> Dictionary:
	return {"block": block, "key": key, "card": card, "port": port, "kind": kind}


## The value of a link from the Tokens window: it stands for nothing yet.
static func blank() -> Dictionary:
	return {"link": ""}


## The value a carried link holds: of variable [param name], or of the object at target path [param path].
static func of_variable(name: String) -> Dictionary:
	return {"link": VARIABLE, "name": name}


static func of_target(path: String) -> Dictionary:
	return {"link": TARGET, "path": path}


## Whether [param value] is a link's (from the tray or carried), not a token's.
static func is_link_value(value: Variant) -> bool:
	return value is Dictionary and (value as Dictionary).has("link")


## Whether Link preview [param preview] shows a variable's name on its link.
static func shows_name(preview: StringName) -> bool:
	return preview in [XREFeatureSettings.VARIABLES, XREFeatureSettings.ALL]


## Whether Link preview [param preview] shows an object's projection on its link.
static func shows_projection(preview: StringName) -> bool:
	return preview in [XREFeatureSettings.OBJECTS, XREFeatureSettings.ALL]


## What a link to the target of [param block] says under Link preview
## [param preview] and Targets [param targets]: "link", or with the projection
## shown the object's name — its member with Targets on Scene, where the member
## would be on a petal at the object, which the hidden wire takes away.
static func target_text(block: Dictionary, preview: StringName, targets: StringName) -> String:
	if not shows_projection(preview): return "link"
	if XREBlueprintTokens.member_on_stem(targets) and not XREBlueprintTokens.member_key(block).is_empty(): return XREBlueprintTokens.adapter_text(block)
	var target := str((block["params"] as Dictionary).get("target", "."))
	return "self" if target in [".", ""] else target.get_file()
