extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM,
	RIGHT
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
@export var cost_multiplier: float
