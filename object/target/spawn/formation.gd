extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
@export var cost_multiplier: float
