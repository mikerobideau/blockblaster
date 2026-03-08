extends Target
class_name EnemyPopup

@export var popup_distance := 50.0
@export var popup_time := 0.15
@export var wait_to_pop_down := 2.0

var start_pos: Vector2

func _ready():
	rotation = -PI / 2 if direction == Vector2.LEFT else PI / 2
	_popup()
	
func _popup():
	start_pos = global_position
	var end_pos = global_position + direction * popup_distance
	var tween = create_tween()
	tween.tween_property(self, 'global_position', end_pos, popup_time)	
	tween.tween_callback(_fire)
	tween.tween_interval(wait_to_pop_down)
	tween.tween_callback(_pop_down)
	
func _pop_down():
	var end_pos = start_pos
	var tween = create_tween()
	tween.tween_property(self, 'global_position', start_pos, popup_time)	
	tween.tween_callback(_remove)

func _physics_process(delta: float):
	pass
	#global_position += direction * speed * delta
