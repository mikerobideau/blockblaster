extends Area2D
class_name Target

signal defeated(target: Area2D)
signal removed(target: Area2D)

var default_debris_texture_1 = preload("res://asset/space-shooter-game-kit/Enemy-spaceship-game-sprites/PNG/Ship_Effects/Ship_Fragment_1.png")
var default_debris_texture_2 = preload("res://asset/space-shooter-game-kit/Enemy-spaceship-game-sprites/PNG/Ship_Effects/Ship_Fragment_3.png")

const SHIP_COLLISION_DAMAGE = 1

enum TargetType {
	SNAKE,
	HAWK,
	WHALE,
	DRAGON,
	METEOR,
	COMET,
	BOMB
}

@onready var sprite = $Sprite2D
@onready var emitter = $Emitter
@onready var hit_box = $HitBox
@onready var fire_timer = $FireTimer
@onready var burst_timer = $BurstTimer
@onready var animation_player = $AnimationPlayer
@onready var explosion = $Explosion
@onready var debris1 = $DebrisParticles
@onready var debris2 = $DebrisParticles2
@onready var tail = $Tail
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
var spawn_position: Vector2
var distance_traveled := 0.0
var is_defeated := false
var all_debris: Array[CPUParticles2D]
var is_exiting := false

func _ready():
	scale = data.scale
	sprite.play('default')
	spawn_position = global_position
	health = data.health
	_init_debris()
	if data.randomize_rotation:
		rotation = randf() * TAU
	if data.movement:
		speed = data.movement.speed
		if !data.randomize_rotation:
			rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
		
	if data.blaster != null:
		burst_shots_remaining = data.blaster.burst_size
		fire_timer.wait_time = data.blaster.fire_timeout
		fire_timer.timeout.connect(_fire)
		burst_timer.wait_time = data.blaster.burst_delay
		burst_timer.timeout.connect(_burst_fire)
		if data.blaster.autostart:
			fire_timer.start()
	if data.movement is PathMovement or data.movement is TravelToPointMovement:
		var center = get_viewport_rect().size / 2
		direction = data.movement.get_direction(global_position, center)


func _init_debris():
	debris1.texture = data.debris_texture_1 if data.debris_texture_1 else default_debris_texture_1
	debris2.texture = data.debris_texture_2 if data.debris_texture_2 else default_debris_texture_2
	all_debris = [debris1, debris2]
	for debris in all_debris:
		debris.initial_velocity_min = data.debris_initial_velocity_min if data.debris_initial_velocity_min else debris.initial_velocity_min
		debris.initial_velocity_max = data.debris_initial_velocity_max if data.debris_initial_velocity_max else debris.initial_velocity_max
		debris.scale_amount_min = data.debris_scale_amount_min if data.debris_scale_amount_min else debris.scale_amount_min
		debris.scale_amount_max = data.debris_scale_amount_max if data.debris_scale_amount_max else debris.scale_amount_max
		debris.emission_sphere_radius = data.debris_sphere_radius if data.debris_sphere_radius else debris.sphere_radius

func _physics_process(delta: float):
	if !data.movement:
		return
	if data.movement is TrackPlayerMovement:
		_track_player_movement(delta)
	if data.movement is TrackEnemyMovement:
		_track_parent_target_movement(delta)
	if data.movement is PathMovement:
		_path_movement(delta)
	if data.movement is TravelToPointMovement:
		_travel_to_point_movement(delta)
		
func _track_player_movement(delta: float):
	var direction = (ship.global_position - global_position).normalized()
	var target_angle = direction.angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

	#slow down near min distance
	var distance = global_position.distance_to(ship.global_position)
	var stop_radius = data.movement.min_distance
	var slow_radius = stop_radius + 150
	var t = clamp((distance - stop_radius) / (slow_radius - stop_radius), 0, 1)
	var smooth_t = t * t * (3 - 2 * t)


	global_position += direction * speed * smooth_t * delta
		
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
			if !data.randomize_rotation:
				rotation = _rotate_towards_direction(delta)
		PathMovement.Type.STRAIGHT_DOWN:
			pass
		PathMovement.Type.DRIFT:
			pass
		PathMovement.Type.S_ACROSS:
			_s_across_movement(delta)
	_move(delta)
	
func _rotate_towards_direction(delta: float) -> float:
	var target_angle = direction.angle() + sprite_forward_offset
	return lerp_angle(rotation, target_angle, rotation_speed * delta)
			
func _move(delta: float):
	global_position += speed * direction * delta

func _s_across_movement(delta: float):
	var amplitude := 80.0
	var frequency := 2.0
	rotation = _rotate_towards_direction(delta)
	global_position.x += direction.x * speed * delta
	distance_traveled += speed * delta
	var offset = sin(distance_traveled * frequency * 0.01) * amplitude
	global_position.y = spawn_position.y + offset

func _travel_to_point_movement(delta):
	var movement: TravelToPointMovement = data.movement
	
	match movement.travel_state:
		TravelToPointMovement.TravelState.APPROACH:
			direction = (movement.waypoint - global_position).normalized()
			print_debug('In TravelState.APPROACH and setting direction to ' + str(direction))
			rotation = lerp_angle(
				rotation,
				direction.angle() + sprite_forward_offset,
				rotation_speed * delta
			)
			_move(delta)
			
			if global_position.distance_to(movement.waypoint) < 100:
				movement.travel_state = TravelToPointMovement.TravelState.FIRE
				fire_timer.start()

		TravelToPointMovement.TravelState.FIRE:
			direction = (ship.global_position - global_position).normalized()
			print_debug('In TravelState.FIRE and setting direction to ' + str(direction))
			rotation = _rotate_towards_direction(delta)

		TravelToPointMovement.TravelState.EXIT:
			fire_timer.stop()
			await get_tree().create_timer(data.movement.wait_to_exit).timeout
			if !is_exiting:
				is_exiting = true
				direction = (spawn_position - global_position).normalized()
			rotation = lerp_angle(rotation, direction.angle() + sprite_forward_offset, rotation_speed * delta)
			_move(delta)

func take_damage(amount: int):
	animation_player.stop()
	if data.shake_on_damage:
		animation_player.play('shake')
	health = clamp(health - amount, 0, health)
	if health <= 0:
		Sound.play(Sound.Effect.ENEMY_DEFEATED)
		defeat()
	else:
		Sound.play(Sound.Effect.ENEMY_HIT)
		sprite.play('damaged')

func _on_area_entered(area: Area2D) -> void:
	if defeated:
		return
	if area is Ship:
		ship.take_damage(SHIP_COLLISION_DAMAGE)

func defeat():
	if is_defeated:
		return
	is_defeated = true
	sprite.visible = false
	_start_debris()
	if data.yellow_burst_on_defeat:
		explosion.visible = true
		explosion.play('default')
		await explosion.animation_finished
		explosion.queue_free()
	await _await_all_debris()
	defeated.emit(self)
	queue_free()
	
func _start_debris():
	for d in all_debris:
		d.emitting = true

func _await_all_debris():
	for d in all_debris:
		return d.finished

#TODO: Update burst to work with any pattern
func _fire():
	if is_defeated:
		return
	if data.blaster.burst_size > 1:
		burst_shots_remaining = data.blaster.burst_size
		_burst_fire()
		burst_timer.start()
	else:
		_fire_pattern()
	if data.movement is TravelToPointMovement:
		data.movement.travel_state = TravelToPointMovement.TravelState.EXIT

func _fire_pattern():
	Sound.play(data.blaster.sound)
	match data.blaster.pattern:
		EnemyBlasterData.Pattern.LINE:
			_fire_line()
		EnemyBlasterData.Pattern.RING:
			_fire_ring()
		EnemyBlasterData.Pattern.SPREAD:
			_fire_spread()
		EnemyBlasterData.Pattern.PARALLEL_SPREAD:
			_fire_parallel_spread()
		_:
			_fire_line()

func _fire_line():
	var energy = _get_energy_scene()
	get_tree().current_scene.add_child(energy)

func _fire_ring():
	var count = data.blaster.projectile_count
	var angle_step = TAU / count
	for i in range(count):
		var energy = _get_energy_scene()
		var dir = Vector2.UP.rotated(rotation + i * angle_step)
		energy.direction = dir
		energy.rotation = dir.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)

func _fire_spread():
	var count = data.blaster.projectile_count
	var spread = deg_to_rad(90) # width of the semicircle arc
	var step = spread / (count - 1)
	for i in range(count):
		var angle_offset = -spread/2 + i * step
		var dir = Vector2.UP.rotated(rotation + angle_offset)
		var energy = _get_energy_scene()
		energy.direction = dir
		energy.rotation = dir.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)

func _fire_parallel_spread():
	var count = data.blaster.projectile_count
	var spacing = 50.0
	var forward = Vector2.UP.rotated(rotation)
	var right = forward.orthogonal()  # perpendicular vector
	for i in range(count):
		var offset_index = i - (count - 1) / 2.0
		var spawn_pos = emitter.global_position + right * offset_index * spacing
		var energy = _get_energy_scene()
		energy.global_position = spawn_pos
		energy.direction = forward
		energy.rotation = forward.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)

func _burst_fire():
	_fire_pattern()
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
	energy.scale = data.blaster.scale
	return energy

func _remove():
	queue_free()
	removed.emit(self)

func _to_center() -> int:
	var viewport = get_viewport_rect().size
	return (viewport / 2) - global_position
	
func _flip_horizontal(direction: Vector2):
	return -PI / 2 if direction == Vector2.LEFT else PI / 2
