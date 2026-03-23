extends BaseBlaster
class_name PlayerBlaster

signal vacuum_started()
signal vacuum_stopped()
signal ability1_fired()

const default_blaster_data = preload("res://resource/blaster/pea_shooter.tres")

@export var vacuum_radius := 50

var firing := false
var ultimate_active := false
var ultimate: Ultimate
var ability1: Cooldown
var ship: Ship

@onready var ultimate_timer = $UltimateTimer

func _ready():
	source = Energy.Source.PLAYER
	data = default_blaster_data
	ultimate_timer.timeout.connect(_on_ultimate_complete)

func setup(b: BlasterData, emit_from: Node2D):
	super.setup(b, emit_from)
	fire_timer.stop()

func set_ship(s: Ship):
	ship = s
	emitter = s.emitter

func set_ultimate(u: Ultimate):
	ultimate = u

func set_ability1(a: Cooldown):
	ability1 = a

func _input(event):
	if event.is_action_pressed('primary'):
		firing = true
		_blast()
		fire_timer.start()
	elif event.is_action_released('primary'):
		firing = false
		fire_timer.stop()
	elif event.is_action_pressed('secondary'):
		vacuum_started.emit()
	elif event.is_action_released('secondary'):
		vacuum_stopped.emit()
	elif event.is_action_pressed('ultimate'):
		_ultimate()
	#elif event.is_action_pressed('ability1'):
	#	ability1_fired.emit(get_global_mouse_position())
	#	ability1.reset_cooldown()

func _on_fire_timer():
	_blast()

func _blast():
	if not firing:
		return
	var dir = (get_global_mouse_position() - emitter.global_position).normalized()
	var dmg = data.ultimate_damage if ultimate_active else -1
	fire_toward(dir, dmg)

func _ultimate():
	if ultimate.fully_charged():
		ultimate_active = true
		ultimate_timer.wait_time = data.ultimate_duration
		ultimate_timer.start()

func _on_ultimate_complete():
	ultimate_active = false
	ultimate.reset_charge()
