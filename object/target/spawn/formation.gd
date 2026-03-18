extends Resource
class_name Formation

enum SpawnPattern {
	RANDOM,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	PINCER,
	#STREAM_RANDOM #in quick succession from any edge
	#STREAM_LINE, #e.g., s line
	#STAGGERED_EDGE #i.e., popup
	#APPEAR_INSIDE #e.g., spawns in play area
}

@export var targets: Array[Target.TargetType]
@export var pattern: SpawnPattern
@export var count: int = 1
#@export var min_count: int = 1
#@export var max_count: int = 1
@export var cost_multiplier: float
#@export var single_edge := false
#@export var mixed_target := false
