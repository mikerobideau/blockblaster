extends Target
class_name EnemyPopup

@export var popup_distance := 50.0
@export var popup_time := 0.15
@export var wait_to_queue_free := 3.0

func _ready():
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	_popup()
	
func _popup():
	var end_pos = global_position + direction * popup_distance
	var tween = create_tween()
	tween.tween_property(self, 'global_position', end_pos, popup_time)	
	tween.tween_callback(_fire)
	tween.tween_interval(wait_to_queue_free)
	tween.tween_callback(queue_free)

func _physics_process(delta: float):
	pass
	#global_position += direction * speed * delta
