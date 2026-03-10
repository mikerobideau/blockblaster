extends Area2D
class_name Target

signal defeated(target: Area2D)
signal removed(target: Area2D)

var EnemyEnergyScene = preload("res://object/target/enemy/enemy_energy.tscn")

const DEFAULT_SPEED = 500

@onready var fire_timer = $FireTimer
@onready var emitter = $Emitter
@onready var sprite = $Sprite2D
@onready var hit_box = $HitBox
@onready var ship = get_tree().current_scene.ship

@export var health: float = 2
@export var radius := 100
@export var bullseye_radius = 10
@export var damage = 1
@export var damage_radius := 100
@export var speed: float = DEFAULT_SPEED
@export var direction: Vector2
@export var rotation_speed := 3.0
@export var fire_timeout := 2
@export var is_fragment := false
@export var number_of_fragments = 3
@export var spawn: Node

var sprite_forward_offset := PI / 2

func _ready():
	fire_timer.wait_time = fire_timeout
	fire_timer.timeout.connect(_fire)
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	fire_timer.start()

func _physics_process(delta: float):
	global_position += direction * speed * delta

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

func _fire():
	var energy = _get_energy_scene()
	get_tree().current_scene.add_child(energy)

func _get_energy_scene() -> EnemyEnergy:
	var energy = EnemyEnergyScene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	return energy

func _remove():
	queue_free()
	removed.emit(self)
