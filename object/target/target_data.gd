extends Resource
class_name TargetData

@export var scene: PackedScene
@export var health: int
@export var difficulty: int
@export var speed := 500
@export var has_energy := false
@export var energy_scene: PackedScene
@export var energy_damage := 1
@export var energy_speed := 500
@export var energy_burst_size := 1
@export var energy_burst_delay := 0.2
@export var fire_timeout := 5
@export var supported_patterns: Array[Pattern.Type]
