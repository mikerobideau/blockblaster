extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	PINCER
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
#@export var min_count: int = 1
#@export var max_count: int = 1
@export var cost_multiplier: float
#@export var single_edge := false
#@export var mixed_target := false
