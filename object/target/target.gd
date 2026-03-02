extends CharacterBody2D
class_name Target

var speed: float = 300
@onready var box = $Box

func _ready():
	input_pickable = true
	velocity = _random_up_direction() * speed

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()
	
func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	
	if col:
		velocity = velocity.bounce(col.get_normal())

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed('left_click'):
		_remove()
		
func _remove():
	await _flash()
	queue_free()
	
#--- Animations ---
func _flash():
	var tween = create_tween()
	tween.tween_property(box, 'modulate', Color.GREEN, 0.2)
	await tween.finished
