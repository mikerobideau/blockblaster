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

@export var speed := 400
@export var rotation_speed := 10.0
@export var color := Color.AQUA
@export var invulnerable_color := Color.YELLOW

var invulnerable := false
var ability: Ability

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
	global_position += direction * speed * delta
	var to_cursor = get_global_mouse_position() - global_position
	var cursor_disabled = ability.active and ability.data.disables_cursor
	#if !cursor_disabled:
	#	rotation = to_cursor.angle() + PI / 2

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
