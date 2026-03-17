extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
@export var cost_multiplier: int
