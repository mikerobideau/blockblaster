extends Area2D
class_name EnemyShip

signal defeated(target: Area2D)

var EnemyEnergyScene = preload("res://object/target/enemy/enemy_energy.tscn")

const DEFAULT_SPEED = 100

@onready var fire_timer = $FireTimer
@onready var emitter = $Emitter
@onready var ship = get_tree().current_scene.ship

@export var radius := 100
@export var bullseye_radius = 10
@export var speed: float = DEFAULT_SPEED
@export var health: float = 10
@export var is_fragment := false
@export var number_of_fragments = 3
@export var direction: Vector2

@export var rotation_speed := 3.0
@export var fire_timeout := 2

var sprite_forward_offset := PI / 2

func _ready():
	fire_timer.wait_time = fire_timeout
	fire_timer.timeout.connect(_fire)
	fire_timer.start()

func _physics_process(delta: float):
	if not ship:
		return
	var target_angle = (ship.global_position - global_position).angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func _fire():
	var energy = EnemyEnergyScene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	get_tree().current_scene.add_child(energy)

func take_damage(amount: int):
	health = clamp(health - amount, 0, health)
	if health <= 0:
		defeat()

func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		ship.take_damage(1)

func defeat():
	defeated.emit(self)
	queue_free()
