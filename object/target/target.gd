extends Area2D
class_name Target

signal defeated(target: Area2D)
signal removed(target: Area2D)

const SHIP_COLLISION_DAMAGE = 1

enum TargetType {
	METEOR,
	ENEMY_SHIP,
	MINION
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
var rotation_speed := 50
var sprite_forward_offset = PI / 2
var parent_target: Target

func _ready():
	health = data.health
	speed = data.movement.speed
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	if data.blaster != null:
		burst_shots_remaining = data.blaster.burst_size
		fire_timer.wait_time = data.blaster.fire_timeout
		fire_timer.timeout.connect(_fire)
		burst_timer.wait_time = data.blaster.burst_delay
		burst_timer.timeout.connect(_burst_fire)
		fire_timer.start()
	if data.movement is PathMovement:
		var center = get_viewport_rect().size / 2
		direction = data.movement.get_direction(global_position, center)
	if data.randomize_rotation:
		rotation = randf() * TAU

func _physics_process(delta: float):
	if data.movement is TrackPlayerMovement:
		_track_player_movement(delta)
	if data.movement is TrackEnemyMovement:
		_track_parent_target_movement(delta)
	if data.movement is PathMovement:
		_path_movement(delta)
		
func _track_player_movement(delta: float):
	var direction = (ship.global_position - global_position).normalized()
	var target_angle = direction.angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	if global_position.distance_to(ship.global_position) > data.movement.min_distance:
		global_position += direction * speed * delta
		
func _track_parent_target_movement(delta: float):
	if !parent_target:
		return
	var direction = (parent_target.global_position - global_position).normalized()
	var target_angle = direction.angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	if global_position.distance_to(parent_target.global_position) > data.movement.min_distance:
		global_position += direction * speed * delta

func _path_movement(delta):
	match data.movement.type:
		PathMovement.Type.STRAIGHT_ACROSS:
			var target_angle = direction.angle() + sprite_forward_offset
			rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
		PathMovement.Type.STRAIGHT_DOWN:
			pass
		PathMovement.Type.DRIFT:
			pass
	_move(delta)
			
func _move(delta: float):
	global_position += speed * direction * delta

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
	if data.blaster.burst_size > 1:
		burst_shots_remaining = data.blaster.burst_size
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
	var energy = data.blaster.scene.instantiate()
	energy.global_position = emitter.global_position
	energy.direction = Vector2.UP.rotated(rotation)
	energy.damage = data.blaster.damage
	energy.speed = data.blaster.speed
	energy.rotation = energy.direction.angle() + sprite_forward_offset
	return energy

func _remove():
	queue_free()
	removed.emit(self)

func _to_center() -> int:
	var viewport = get_viewport_rect().size
	return (viewport / 2) - global_position
	
func _flip_horizontal(direction: Vector2):
	return -PI / 2 if direction == Vector2.LEFT else PI / 2
