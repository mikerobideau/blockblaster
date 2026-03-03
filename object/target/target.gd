extends CharacterBody2D
class_name Target

signal defeated(target: Target)

@onready var box = $Box
@onready var hitbox = $HitBox
@onready var bullseye = $Bullseye

const BASE_COLOR = Color.WHITE
const DEFAULT_SPEED = 100
const BULLSEYE_BONUS = 3

@export var radius := 100
@export var bullseye_radius = 10
@export var speed: float = DEFAULT_SPEED
@export var health: float = 10
@export var is_fragment := false
@export var number_of_fragments = 10

var freeze_timer: SceneTreeTimer
var is_frozen := false

func _ready():
	box.size = Vector2(radius, radius)
	box.position = -box.size/2
	
	bullseye.size = Vector2(bullseye_radius, bullseye_radius)
	bullseye.position = -bullseye.size / 2
	
	var rect_shape = hitbox.shape as RectangleShape2D
	rect_shape.extents = box.size / 2
	hitbox.position = Vector2.ZERO
	
	velocity = _random_up_direction() * speed

func _random_up_direction():
	var x = deg_to_rad(randf_range(0, 180))
	return Vector2(cos(x), sin(x)).normalized()
	
func _physics_process(delta: float) -> void:
	var col = move_and_collide(velocity * delta)
	
	if col:
		velocity = velocity.bounce(col.get_normal())
		
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
	update_velocity()
	var timer = get_tree().create_timer(Constant.FREEZE_DURATION)
	unfreeze_after_timeout(timer)
	
func update_velocity():
	if velocity.length() != 0:
		velocity = velocity.normalized() * speed
	
func unfreeze_after_timeout(timer: SceneTreeTimer):
	freeze_timer = timer
	await freeze_timer.timeout
	if timer != freeze_timer:
		return
	is_frozen = false
	speed = DEFAULT_SPEED
	update_velocity()
	
