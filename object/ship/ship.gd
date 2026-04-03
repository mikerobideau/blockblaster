extends Area2D
class_name Ship

signal damage_taken(amount: int)

const SHIP_COLLISION_DAMAGE = 1
const INVULNERABILITY_TIME := 0.75
const DEFAULT_ABILITY_DATA = preload("res://resource/ability/barrel_roll.tres")

@onready var sprite = $Sprite2D
@onready var emitter = $Emitter
@onready var invulnerability_overlay = $InvulnerabilityOverlay
@onready var invulnerability_timer = $InvulnerabilityTimer
@onready var blaster = $Blaster

@export var speed := 700
@export var rotation_speed := 10.0
@export var color := Color.AQUA
@export var invulnerable_color := Color.RED
@export var drag := 0.99
@export var thrust_response := 0.02
@export var bob_amplitude := 40.0
@export var bob_frequency := 0.4
@export var max_tilt_angle := 90.0

var invulnerable := false
var ability: Ability
var velocity := Vector2.ZERO
var bob_time := 0.0

func _ready():
	sprite.play('default')
	equip_ability(DEFAULT_ABILITY_DATA)
	set_invulnerable(false)
	invulnerability_timer.wait_time = INVULNERABILITY_TIME
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)

func _input(event):
	if event.is_action_pressed('ability1'):
		if ability != null and ability.is_ready():
			ability.activate()

func is_player() -> bool:
	return true

func _physics_process(delta: float):
	var direction = Input.get_vector('left', 'right', 'up', 'down')
	var targetvelocity = direction * speed
	velocity = velocity.lerp(targetvelocity, thrust_response)
	velocity *= drag
	bob_time += delta
	var idle_factor = 1.0 - clamp(direction.length(), 0.0, 1.0)
	var bob_offset := Vector2(0.0, sin(bob_time * bob_frequency * TAU) * bob_amplitude * idle_factor)
 
	global_position += (velocity + bob_offset) * delta
 
	#if velocity.length() > 8.0:
	#	var tilt_target := velocity.x / speed * 0.18   # radians, subtle
	#	rotation = lerp(rotation, tilt_target, 6.0 * delta)
	#else:
	#	rotation = lerp(rotation, 0.0, 4.0 * delta)
		
	# Facing: flip left/right to face the cursor, tilt up/down within max_tilt_angle.
	# The ship never rotates past horizontal so it can never appear upside down.
	var cursor_disabled = ability.active and ability.data.disables_cursor
	if !cursor_disabled:
		var to_cursor := get_global_mouse_position() - global_position
		# Horizontal flip — no rotation involved, so no risk of flipping upside down
		sprite.flip_h = to_cursor.x < 0
		# Tilt: measure angle from horizontal using only the vertical component.
		# abs(to_cursor.x) keeps the angle in the right half-plane regardless of facing.
		var raw_angle := rad_to_deg(atan2(to_cursor.y, abs(to_cursor.x)))
		var clamped_angle = clamp(raw_angle, -max_tilt_angle, max_tilt_angle)
		# Invert tilt when facing left so up/down stays consistent with cursor position
		if to_cursor.x < 0:
			clamped_angle = -clamped_angle
		rotation = lerp_angle(rotation, deg_to_rad(clamped_angle), rotation_speed * delta)

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
		
func equip_ability(d: AbilityData):
	ability = d.scene.instantiate()
	add_child(ability)
	ability.setup(d, self)
	
func is_any_ability_active() -> bool:
	return ability.active
