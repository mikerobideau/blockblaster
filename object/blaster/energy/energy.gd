extends Area2D
class_name Energy

@onready var hitBox = $HitBox

@export var damage := 10
@export var radius := 5
@export var color := Color.GREEN
@export var speed := 800

var direction := Vector2.ZERO

func _ready():
	direction = direction.normalized()
	queue_redraw()
	body_entered.connect(_on_body_entered)
	hitBox.shape.radius = radius

func _physics_process(delta: float):
	position += direction * speed * delta

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func _on_body_entered(body: Node) -> void:
	if body is Target:
		body.take_damage(damage, false)
	queue_free()
