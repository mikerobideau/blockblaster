extends Area2D
class_name Ship

signal damage_taken(amount: int)

const SHIP_COLLISION_DAMAGE = 1
@export var INVULNERABILITY_TIME := 0.75

@onready var sprite = $Sprite2D
@onready var emitter = $Emitter
@onready var invulnerability_overlay = $InvulnerabilityOverlay
@onready var invulnerability_timer = $InvulnerabilityTimer

@export var speed := 400
@export var rotation_speed := 10.0
@export var color := Color.AQUA
@export var invulnerable_color := Color.YELLOW

var invulnerable := false

func _ready():
	set_invulnerable(false)
	invulnerability_timer.wait_time = INVULNERABILITY_TIME
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)

func is_player() -> bool:
	return true

func _physics_process(delta: float):
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	global_position += direction * speed * delta
	var to_cursor = get_global_mouse_position() - global_position
	rotation = to_cursor.angle() + PI / 2

func take_damage(amount: int):
	if !invulnerable:
		damage_taken.emit(amount)
		set_invulnerable(true)
		
func _on_invulnerability_timeout():
	set_invulnerable(false)
		
func set_invulnerable(value: bool):
	invulnerable = value
	if value:
		invulnerability_timer.start()
		sprite.self_modulate = Color.YELLOW
	else:
		sprite.self_modulate = Color(1, 1, 1, 1)

func _on_area_entered(area: Area2D) -> void:
	if area is Target:
		area.defeat()
