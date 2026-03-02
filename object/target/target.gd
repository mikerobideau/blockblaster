extends CharacterBody2D
class_name Target

signal defeated(target: Target)

@onready var box = $Box

const BASE_COLOR = Color.WHITE
const DAMAGE_AMOUNT = 5

var speed: float = 300
var health: float = 10

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
		_take_damage(DAMAGE_AMOUNT)
		
func _take_damage(damage: float):
	if health - damage < 0:
		health = 0
	else:
		health -= damage
		await _flash()
	if health == 0:
		_on_defeated()
		
func _on_defeated():
	defeated.emit(self)
	queue_free()
	
#--- Animations ---
func _flash():
	var tween = create_tween()
	tween.tween_property(box, 'modulate', Color.GREEN, 0.1)
	tween.tween_property(box, 'modulate', BASE_COLOR, 0.1)
	await tween.finished
