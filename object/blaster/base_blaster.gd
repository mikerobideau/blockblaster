extends Node2D
class_name BaseBlaster

signal fired()

var sprite_forward_offset = PI / 2
var burst_shots_remaining := 0
var burst_direction := Vector2.ZERO

@onready var fire_timer = $FireTimer
@onready var burst_timer = $BurstTimer

var data: BlasterData
var source := Energy.Source.ENEMY
var emitter: Node2D

func setup(d: BlasterData, emit_from: Node2D):
	if d:
		data = d
		emitter = emit_from
		burst_shots_remaining = data.burst_size
		fire_timer.wait_time = data.fire_timeout
		burst_timer.wait_time = data.burst_delay
		if fire_timer.timeout.is_connected(_on_fire_timer):
			fire_timer.timeout.disconnect(_on_fire_timer)
		if burst_timer.timeout.is_connected(_on_burst_timer):
			burst_timer.timeout.disconnect(_on_burst_timer)
		fire_timer.timeout.connect(_on_fire_timer)
		burst_timer.timeout.connect(_on_burst_timer)
		if data.autostart:
			fire_timer.start()

func fire_toward(direction: Vector2, override_damage := -1):
	_fire_pattern(direction, override_damage)

func _on_fire_timer():
	var dir = Vector2.UP.rotated(emitter.global_rotation)
	_fire_pattern(dir)

func _on_burst_timer():
	if burst_direction == Vector2.ZERO:
		burst_timer.stop()
		return
	_fire_single(burst_direction, data.damage)
	burst_shots_remaining -= 1
	if burst_shots_remaining <= 0:
		burst_timer.stop()
		fired.emit()

func _fire_pattern(dir: Vector2, override_damage := -1):
	var dmg = override_damage if override_damage >= 0 else data.damage
	if data.sound:
		Sound.play(data.sound)
	_fire_single(dir, dmg)
	if data.burst_size > 1:
		burst_direction = dir
		burst_shots_remaining = data.burst_size - 1
		burst_timer.start()
	else:
		fired.emit()

func _fire_single(dir: Vector2, dmg: int):
	match data.pattern:
		BlasterData.Pattern.LINE:
			_fire_line(dir, dmg)
		BlasterData.Pattern.RING:
			_fire_ring(dmg)
		BlasterData.Pattern.SPREAD:
			_fire_spread(dir, dmg)
		BlasterData.Pattern.PARALLEL_SPREAD:
			_fire_parallel_spread(dir, dmg)
		_:
			_fire_line(dir, dmg)

func _make_energy(dmg: int) -> Energy:
	var energy = data.scene.instantiate() as Energy
	energy.source = source
	energy.global_position = emitter.global_position
	energy.damage = dmg
	energy.speed = data.speed
	energy.scale = data.scale
	return energy

func _fire_line(dir: Vector2, dmg: int):
	var energy = _make_energy(dmg)
	energy.direction = dir
	energy.rotation = dir.angle() + sprite_forward_offset
	get_tree().current_scene.add_child(energy)

func _fire_ring(dmg: int):
	var angle_step = TAU / data.projectile_count
	for i in range(data.projectile_count):
		var energy = _make_energy(dmg)
		var dir = Vector2.UP.rotated(emitter.global_rotation + i * angle_step)
		energy.direction = dir
		energy.rotation = dir.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)

func _fire_spread(dir: Vector2, dmg: int):
	var spread = deg_to_rad(90)
	var step = spread / max(data.projectile_count - 1, 1)
	for i in range(data.projectile_count):
		var energy = _make_energy(dmg)
		var angle_offset = -spread / 2 + i * step
		var d = dir.rotated(angle_offset)
		energy.direction = d
		energy.rotation = d.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)

func _fire_parallel_spread(dir: Vector2, dmg: int):
	var spacing = 50.0
	var right = dir.orthogonal()
	for i in range(data.projectile_count):
		var energy = _make_energy(dmg)
		var offset_index = i - (data.projectile_count - 1) / 2.0
		energy.global_position = emitter.global_position + right * offset_index * spacing
		energy.direction = dir
		energy.rotation = dir.angle() + sprite_forward_offset
		get_tree().current_scene.add_child(energy)
