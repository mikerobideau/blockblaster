extends Area2D
class_name Gold

@export var radius := 10
@export var color := Color.YELLOW
@export var speed := 50
@export var velocity: Vector2

func _ready():
	velocity = _random_up_direction() * speed

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _process(delta):
	global_position += velocity * delta
