extends CharacterBody2D
class_name Ship

@onready var emitter = $Emitter

@export var speed := 400
@export var rotation_speed := 10.0

func _physics_process(delta: float):
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	velocity = direction * speed
	move_and_slide()
	
	var to_cursor = get_global_mouse_position() - global_position
	rotation = to_cursor.angle() + PI / 2
