class_name XREDemoStats
extends Resource
## A character's numbers, a data class for Break and Make in Blueprints
## (D-135): what Break takes apart and Make puts together. Also used by the tests.

@export var hp: int = 100
@export var speed: float = 2.5
var title: String = "hero"
## A value the class keeps to itself: Break shows it hidden at first.
var _cooldown: float = 0.0
