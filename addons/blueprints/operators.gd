@tool
class_name XREBlueprintOperators
extends RefCounted
## The operators of an Operator block (D-065): arithmetic, comparison and
## logic, drawn as in Unreal — the inputs, the symbol between them, the result.
## The block's operands take any value an operator works on; the result's type
## follows them ([method result_type]): integers give an integer, a vector and
## a number a vector. Generated scripts evaluate them here ([method evaluate]),
## after [method problem] has checked the values that came.

## Groups: arithmetic, equality, order and logic.
const MATH := &"math"
const EQUALITY := &"equality"
const ORDER := &"order"
const LOGIC := &"logic"
## A combination of operands an operator can't take.
const INVALID := -1
## What each operator is: its symbol on a card, its title, its group, its
## search words; [code]unary[/code] for one operand.
const OPERATORS := {
	"add": {"symbol": "+", "title": "Add", "group": MATH, "keywords": "plus sum + join"},
	"subtract": {"symbol": "−", "title": "Subtract", "group": MATH, "keywords": "minus difference -"},
	"multiply": {"symbol": "×", "title": "Multiply", "group": MATH, "keywords": "times product * scale"},
	"divide": {"symbol": "÷", "title": "Divide", "group": MATH, "keywords": "quotient / over"},
	"modulo": {"symbol": "%", "title": "Modulo", "group": MATH, "keywords": "remainder mod %"},
	"negate": {"symbol": "−", "title": "Negate", "group": MATH, "unary": true, "keywords": "minus opposite invert -"},
	"not_equal": {"symbol": "≠", "title": "Not Equal", "group": EQUALITY, "keywords": "!= different compare"},
	"less": {"symbol": "<", "title": "Less", "group": ORDER, "keywords": "< smaller compare"},
	"less_equal": {"symbol": "≤", "title": "Less or Equal", "group": ORDER, "keywords": "<= at most compare"},
	"greater": {"symbol": ">", "title": "Greater", "group": ORDER, "keywords": "> larger bigger compare"},
	"greater_equal": {"symbol": "≥", "title": "Greater or Equal", "group": ORDER, "keywords": ">= at least compare"},
	"and": {"symbol": "AND", "title": "AND", "group": LOGIC, "keywords": "both && logic boolean"},
	"or": {"symbol": "OR", "title": "OR", "group": LOGIC, "keywords": "either || logic boolean"},
	"not": {"symbol": "NOT", "title": "NOT", "group": LOGIC, "unary": true, "keywords": "! invert logic boolean"},
}
## The menu's sections of the groups, in order; Equal (an Equal block) heads Comparison.
const SECTIONS := {MATH: "Math", EQUALITY: "Comparison", ORDER: "Comparison", LOGIC: "Logic"}
const NUMBERS: Array[int] = [TYPE_INT, TYPE_FLOAT]
## Values that add and scale component by component.
const VECTORS: Array[int] = [TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]
## What [method result_type] says of operands that may not be known until the game runs.
const UNKNOWN := TYPE_NIL


## The group of operator [param op], empty for an unknown one.
static func group_of(op: String) -> StringName:
	return (OPERATORS[op] as Dictionary)["group"] if OPERATORS.has(op) else &""


## Whether operator [param op] takes one operand.
static func is_unary(op: String) -> bool:
	return OPERATORS.has(op) and bool((OPERATORS[op] as Dictionary).get("unary", false))


## The parameters a new block of operator [param op] starts with: its
## operands' literals, numbers for arithmetic and order, false for logic.
## Multiplication, division and modulo start at 1, so that they change nothing.
static func default_params(op: String) -> Dictionary:
	var group := group_of(op)
	var first: Variant = false if group == LOGIC else 0.0
	var second: Variant = false if group == LOGIC else (1.0 if op in ["multiply", "divide", "modulo"] else 0.0)
	var params := {"op": op, "a": first}
	if not is_unary(op): params["b"] = second
	return params


## The Variant type of [param op]'s result for operands of types [param a]
## and [param b] ([constant TYPE_NIL] for one not known before the game runs);
## [constant UNKNOWN] when it depends on such an operand, [constant INVALID]
## when no values of these types work.
static func result_type(op: String, a: int, b: int) -> int:
	if not OPERATORS.has(op): return INVALID
	var unary := is_unary(op)
	match group_of(op):
		LOGIC: return TYPE_BOOL if _fits(a, [TYPE_BOOL]) and (unary or _fits(b, [TYPE_BOOL])) else INVALID
		ORDER: return TYPE_BOOL if _fits(a, NUMBERS) and _fits(b, NUMBERS) else INVALID
		EQUALITY: return TYPE_BOOL
	if unary: return a if a in [UNKNOWN, TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3] else INVALID
	if a == UNKNOWN or b == UNKNOWN: return UNKNOWN
	if a in NUMBERS and b in NUMBERS: return TYPE_INT if a == TYPE_INT and b == TYPE_INT else TYPE_FLOAT
	if op == "add" and a == TYPE_STRING and b == TYPE_STRING: return TYPE_STRING
	if op == "modulo": return INVALID
	if a == b and a in VECTORS: return a
	if a in VECTORS and b in NUMBERS and op in ["multiply", "divide"]: return a
	if b in VECTORS and a in NUMBERS and op == "multiply": return b
	return INVALID


static func _fits(type: int, types: Array[int]) -> bool:
	return type == UNKNOWN or type in types


## What is wrong with [param op] on [param a] and [param b] (null for a unary
## one), or empty: types it can't take, an integer division by zero.
static func problem(op: String, a: Variant, b: Variant = null) -> String:
	var second := typeof(b) if not is_unary(op) else TYPE_NIL
	if result_type(op, typeof(a), second) == INVALID:
		return describe(op, typeof(a), second)
	if op in ["divide", "modulo"] and a is int and b is int and int(b) == 0:
		return "Division by zero."
	return ""


## Why [param op] can't take operands of types [param a] and [param b], for a diagnostic.
static func describe(op: String, a: int, b: int) -> String:
	var title := str((OPERATORS[op] as Dictionary)["title"]) if OPERATORS.has(op) else op
	if is_unary(op): return "%s doesn't take %s." % [title, type_string(a)]
	return "%s doesn't take %s and %s." % [title, type_string(a), type_string(b)]


## The result of [param op] on [param a] and [param b], which [method problem] has passed.
static func evaluate(op: String, a: Variant, b: Variant = null) -> Variant:
	match op:
		"add": return a + b
		"subtract": return a - b
		"multiply": return a * b
		"divide": return a / b
		"modulo": return a % b if a is int and b is int else fmod(float(a), float(b))
		"negate": return -a
		"not_equal": return not equal(a, b)
		"less": return a < b
		"less_equal": return a <= b
		"greater": return a > b
		"greater_equal": return a >= b
		"and": return bool(a) and bool(b)
		"or": return bool(a) or bool(b)
		"not": return not bool(a)
	return null


## Equality as an Equal block has it: values of different types differ, but an
## integer and a real are both numbers.
static func equal(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b) and not (typeof(a) in NUMBERS and typeof(b) in NUMBERS):
		return false
	return a == b
