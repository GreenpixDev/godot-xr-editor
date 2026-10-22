"""Generates addons/blueprints/global_functions.gd (XREBlueprintGlobals, D-051) from the
utility_functions of `godot --headless --dump-extension-api` of the pinned Godot 4.7.2.

Usage: py scripts/gen_blueprint_globals.py extension_api.json addons/blueprints/global_functions.gd
"""
import json, sys, io
api = json.load(open(sys.argv[1], encoding="utf-8"))
TYPES = {"Nil": "TYPE_NIL", "bool": "TYPE_BOOL", "int": "TYPE_INT", "float": "TYPE_FLOAT", "String": "TYPE_STRING",
	"Vector2": "TYPE_VECTOR2", "Vector2i": "TYPE_VECTOR2I", "Rect2": "TYPE_RECT2", "Rect2i": "TYPE_RECT2I", "Vector3": "TYPE_VECTOR3",
	"Vector3i": "TYPE_VECTOR3I", "Transform2D": "TYPE_TRANSFORM2D", "Vector4": "TYPE_VECTOR4", "Vector4i": "TYPE_VECTOR4I",
	"Plane": "TYPE_PLANE", "Quaternion": "TYPE_QUATERNION", "AABB": "TYPE_AABB", "Basis": "TYPE_BASIS", "Transform3D": "TYPE_TRANSFORM3D",
	"Projection": "TYPE_PROJECTION", "Color": "TYPE_COLOR", "StringName": "TYPE_STRING_NAME", "NodePath": "TYPE_NODE_PATH", "RID": "TYPE_RID",
	"Object": "TYPE_OBJECT", "Callable": "TYPE_CALLABLE", "Signal": "TYPE_SIGNAL", "Dictionary": "TYPE_DICTIONARY", "Array": "TYPE_ARRAY",
	"PackedByteArray": "TYPE_PACKED_BYTE_ARRAY", "PackedInt32Array": "TYPE_PACKED_INT32_ARRAY", "PackedInt64Array": "TYPE_PACKED_INT64_ARRAY",
	"PackedFloat32Array": "TYPE_PACKED_FLOAT32_ARRAY", "PackedFloat64Array": "TYPE_PACKED_FLOAT64_ARRAY", "PackedStringArray": "TYPE_PACKED_STRING_ARRAY",
	"PackedVector2Array": "TYPE_PACKED_VECTOR2_ARRAY", "PackedVector3Array": "TYPE_PACKED_VECTOR3_ARRAY", "PackedColorArray": "TYPE_PACKED_COLOR_ARRAY",
	"PackedVector4Array": "TYPE_PACKED_VECTOR4_ARRAY", "Variant": "TYPE_NIL"}
out = io.StringIO()
out.write("@tool\nclass_name XREBlueprintGlobals\nextends RefCounted\n")
out.write("## Utility functions of @GlobalScope that a Blueprint Call block can use (D-051).\n")
out.write("## The engine has no runtime list of them: this table is generated once from\n")
out.write("## [code]godot --dump-extension-api[/code] of the pinned Godot 4.7.2 (utility_functions)\n")
out.write("## by scripts/gen_blueprint_globals.py. A Variant argument or result is TYPE_NIL.\n\n")
out.write("## Function name: its category, result type, arguments as [name, type], and whether it takes more arguments.\n")
out.write("const FUNCTIONS: Dictionary[String, Dictionary] = {\n")
for f in api["utility_functions"]:
	args = ", ".join('["%s", %s]' % (a["name"], TYPES[a["type"]]) for a in f.get("arguments", []))
	ret = TYPES[f.get("return_type", "Nil")] if "return_type" in f else "TYPE_NIL"
	out.write('\t"%s": {"category": "%s", "return": %s, "returns": %s, "args": [%s], "vararg": %s},\n' % (
		f["name"], f["category"], ret, "true" if "return_type" in f else "false", args, "true" if f["is_vararg"] else "false"))
out.write("}\n")
open(sys.argv[2], "w", encoding="utf-8", newline="\n").write(out.getvalue())
print(len(api["utility_functions"]))
