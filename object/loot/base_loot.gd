extends Area2D
class_name BaseLoot

@onready var lifetime_timer = $LifetimeTimer

@export var value := 1
@export var speed := 50
@export var velocity: Vector2
@export var vacuum_accel := 600
@export var max_speed := 400
@export var lifetime := 5

var being_vacuumed := false
var blaster: Blaster
var ship: Ship

func _ready():
	velocity = _random_up_direction() * speed
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(remove)
	lifetime_timer.start()

func _process(delta):
	if being_vacuumed:
		var destination = ship.global_position
		var dir = destination - global_position
		var dist = dir.length()
		if dist < blaster.vacuum_radius:
			global_position = destination
			velocity = Vector2.ZERO
		velocity = velocity.move_toward(
			dir.normalized() * max_speed,
			vacuum_accel * delta
		)
		velocity = velocity.limit_length(max_speed)
	global_position += velocity * delta

func set_ship(s: Ship):
	ship = s

func set_blaster(b: Blaster):
	blaster = b
	blaster.vacuum_started.connect(_on_vacuum_started)
	blaster.vacuum_stopped.connect(_on_vacuum_stopped)

func _on_vacuum_started():
	being_vacuumed = true

func _on_vacuum_stopped():
	being_vacuumed = false

func _random_up_direction() -> Vector2:
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()

func _on_area_entered(area: Area2D) -> void:
	if area is Ship:
		_collect()

#Override in subclass
func _collect():
	queue_free()
	
func remove():
	print_debug('queuing coin free')
	queue_free()
