extends Resource
class_name SpawnGroupData

enum SpawnPattern {
	RANDOM
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
@export var cost_multiplier: int
