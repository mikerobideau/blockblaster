extends Area2D
class_name Target

signal defeated(target: Area2D)
signal removed(target: Area2D)

enum TargetType {
	#METEOR,
	ENEMY_SHIP,
	#HOMING,
	#PATROL,
	#POPUP
}

var EnemyEnergyScene = preload("res://object/target/enemy/enemy_energy.tscn")

@onready var sprite = $Sprite2D
@onready var emitter = $Emitter
@onready var hit_box = $HitBox
@onready var fire_timer = $FireTimer
@onready var ship = get_tree().current_scene.ship

@export var data: TargetData
@export var damage = 1
@export var damage_radius := 100
@export var direction: Vector2
@export var fire_timeout := 2

var health: int
var speed: int

func _ready():
	health = data.health
	speed = data.speed
	fire_timer.wait_time = fire_timeout
	fire_timer.timeout.connect(_fire)
	direction = Vector2.RIGHT if _is_in_left_hemisphere() else Vector2.LEFT
	rotation = _flip_horizontal(direction)
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	#fire_timer.start()

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

func _to_center() -> int:
	var viewport = get_viewport_rect().size
	return (viewport / 2) - global_position
	
func _is_in_left_hemisphere() -> bool:
	var center_x = get_viewport_rect().size.x / 2
	return global_position.x < center_x
	
func _is_in_right_hemisphere() -> bool:
	var center_x = get_viewport_rect().size.x / 2
	return global_position.x > center_x
	
func _flip_horizontal(direction: Vector2):
	return -PI / 2 if direction == Vector2.LEFT else PI / 2
