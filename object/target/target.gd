extends Area2D
class_name Target

signal defeated(target: Target)

@onready var box = $Box
@onready var hitbox = $HitBox
@onready var bullseye = $Bullseyeb

const BASE_COLOR = Color.WHITE
const DEFAULT_SPEED = 100
const BULLSEYE_BONUS = 3

@export var radius := 100
@export var bullseye_radius = 10
@export var speed: float = DEFAULT_SPEED
@export var health: float = 10
@export var is_fragment := false
@export var number_of_fragments = 3
@export var direction: Vector2

var freeze_timer: SceneTreeTimer
var is_frozen := false
	
func _ready():
	_start()
	
func _start():
	direction = _random_up_direction()

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()
	
func _physics_process(delta: float) -> void:
	position += speed * direction * delta
	
	var screen_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)
	if position.x < 0 or position.x > screen_rect.size.x:
		direction.x = -direction.x
		position.x = clamp(position.x, 0, screen_rect.size.x)
	if position.y < 0 or position.y > screen_rect.size.y:
		direction.y = -direction.y
		position.y = clamp(position.y, 0, screen_rect.size.y)
		
func _on_defeated():
	defeated.emit(self)
	queue_free()
	
#--- Animations ---
func _flash(color: Color):
	var tween = create_tween()
	tween.tween_property(box, 'modulate', color, 0.1)
	tween.tween_property(box, 'modulate', BASE_COLOR, 0.1)
	await tween.finished
	
#--- Public --- 
func take_damage(amount: float, is_bullseye: bool):
	var color: Color
	if is_bullseye:
		amount += BULLSEYE_BONUS
		color = Color.YELLOW
	else:
		color = Color.GREEN
	if health - amount < 0:
		health = 0
	else:
		health -= amount
		await _flash(color)
	if health == 0:
		_on_defeated()
		
func freeze(amount: float):
	is_frozen = true
	if speed < amount:
		speed = 0
	else:
		speed -= amount
	var timer = get_tree().create_timer(Constant.FREEZE_DURATION)
	unfreeze_after_timeout(timer)
	
func unfreeze_after_timeout(timer: SceneTreeTimer):
	freeze_timer = timer
	await freeze_timer.timeout
	if timer != freeze_timer:
		return
	is_frozen = false
	speed = DEFAULT_SPEED

func _on_area_entered(area: Area2D):
	print_debug('target area entered')
	if area is Ship:
		area.take_damage(1)
