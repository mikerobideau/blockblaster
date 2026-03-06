extends CharacterBody2D
class_name Ship

signal take_damage(amount: int)

const SHIP_COLLISION_DAMAGE = 1
@export var INVULNERABILITY_TIME := 0.75

@onready var sprite = $Sprite2D
@onready var hit_box = $HitBox
@onready var emitter = $Emitter
@onready var invulnerability_overlay = $InvulnerabilityOverlay
@onready var invulnerability_timer = $InvulnerabilityTimer

@export var speed := 400
@export var rotation_speed := 10.0
@export var color := Color.AQUA
@export var invulnerable_color := Color.YELLOW

var invulnerable := false
var overlapping_targets: Array[Target] = []

func _ready():
	set_invulnerable(false)
	invulnerability_timer.wait_time = INVULNERABILITY_TIME
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
	hit_box.body_entered.connect(_on_body_entered)
	hit_box.body_exited.connect(_on_body_exited)

func is_player() -> bool:
	return true

func _physics_process(delta: float):
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	velocity = direction * speed
	move_and_slide()
	
	var to_cursor = get_global_mouse_position() - global_position
	rotation = to_cursor.angle() + PI / 2

func _on_body_entered(body: Node):
	if body is Target:
		if !overlapping_targets.has(body):
			overlapping_targets.append(body)
	if !invulnerable and body is Target:
		apply_hit()
		
func _on_body_exited(body: Node):
	if body is Target:
		overlapping_targets.erase(body)
		
func apply_hit():
		take_damage.emit(SHIP_COLLISION_DAMAGE)
		set_invulnerable(true)
		
func _on_invulnerability_timeout():
	set_invulnerable(false)
	if overlapping_targets.size() > 0:
		apply_hit()
		
func set_invulnerable(value: bool):
	invulnerable = value
	if value:
		invulnerability_timer.start()
		sprite.self_modulate = Color.YELLOW
	else:
		sprite.self_modulate = Color(1, 1, 1, 1)
