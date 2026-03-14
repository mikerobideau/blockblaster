extends Area2D
class_name Target

signal defeated(target: Area2D)
signal removed(target: Area2D)

const SHIP_COLLISION_DAMAGE = 1

enum TargetType {
	#METEOR,
	ENEMY_SHIP,
	#HOMING,
	#PATROL,
	#POPUP
}

@onready var sprite = $Sprite2D
@onready var emitter = $Emitter
@onready var hit_box = $HitBox
@onready var fire_timer = $FireTimer
@onready var burst_timer = $BurstTimer
@onready var ship = get_tree().current_scene.ship

@export var data: TargetData

var health: int
var speed: int
var damage: int
var fire_timeout: int
var direction: Vector2
var burst_shots_remaining: int

func _ready():
	health = data.health
	speed = data.speed
	burst_shots_remaining = data.energy_burst_size
	fire_timer.wait_time = data.fire_timeout
	fire_timer.timeout.connect(_fire)
	burst_timer.wait_time = data.energy_burst_delay
	burst_timer.timeout.connect(_burst_fire)
	direction = Vector2.RIGHT if _is_in_left_hemisphere() else Vector2.LEFT
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	if data.has_energy:
		fire_timer.start()

func _physics_process(delta: float):
	global_position += direction * speed * delta

func take_damage(amount: int):
	health = clamp(health - amount, 0, health)
	if health <= 0:
		defeat()

func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		ship.take_damage(SHIP_COLLISION_DAMAGE)

func defeat():
	defeated.emit(self)
	queue_free()

func _fire():
	if data.energy_burst_size > 1:
		burst_shots_remaining = data.energy_burst_size
		_burst_fire()
		burst_timer.start()
	else:
		var energy = _get_energy_scene()
		get_tree().current_scene.add_child(energy)

func _burst_fire():
	var energy = _get_energy_scene()
	get_tree().current_scene.add_child(energy)
	burst_shots_remaining -= 1
	if burst_shots_remaining <= 0:
		burst_timer.stop()
	else:
		burst_timer.start()

func _get_energy_scene() -> EnemyEnergy:
	var energy = data.energy_scene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	energy.damage = data.energy_damage
	energy.speed = data.energy_speed
	energy.rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
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
