extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	PINCER,
	TOP_MARCH,
	APPEAR
}

@export var targets: Array[Target.TargetType]
@export var count: int = 1
@export var pattern: SpawnPattern
@export var has_shared_position := false

#@export var min_count: int = 1
#@export var max_count: int = 1
@export var cost_multiplier := 1
#@export var single_edge := false
#@export var mixed_target := false
@export var stream_interval := 0.0
