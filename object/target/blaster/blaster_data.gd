extends Resource
class_name EnemyBlasterData

enum Pattern {
	LINE,
	RING
}

@export var scene: PackedScene
@export var autostart := false
@export var pattern := Pattern.LINE
@export var damage := 1
@export var speed := 500
@export var burst_size := 1
@export var burst_delay := 0.2
@export var fire_timeout := 5
