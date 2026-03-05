extends CharacterBody2D
class_name Ship

signal take_damage(amount: int)

@onready var emitter = $Emitter
@onready var hitBox = $HitBox

@export var speed := 400
@export var rotation_speed := 10.0

func _ready():
	hitBox.body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	velocity = direction * speed
	move_and_slide()
	
	var to_cursor = get_global_mouse_position() - global_position
	rotation = to_cursor.angle() + PI / 2

func _on_body_entered(body: Node):
	if body is Target:
		take_damage.emit(1)
