extends Target
class_name Wimpy

var EnemyEnergyScene = preload("res://object/target/enemy/enemy_energy.tscn")

@onready var fire_timer = $FireTimer
@onready var emitter = $Emitter
@onready var ship = get_tree().current_scene.ship

@export var rotation_speed := 3.0  # radians per second

var sprite_forward_offset := PI / 2  # adjust depending on which way your sprite faces

func _ready():
	fire_timer.timeout.connect(_fire)
	fire_timer.start()

func _physics_process(delta: float):
	if not ship:
		return

	# Smoothly rotate toward the ship
	var target_angle = (ship.global_position - global_position).angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)


func _fire():
	# Spawn projectile going forward along current rotation
	var energy = EnemyEnergyScene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	get_tree().current_scene.add_child(energy)
