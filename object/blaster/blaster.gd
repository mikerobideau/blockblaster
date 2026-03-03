extends Node2D
class_name Blaster

signal fired(position: Vector2)
signal vacuum_started()
signal vacuum_stopped()

@onready var fire_timer = $FireTimer
@onready var crosshair = $Crosshair

@export var damage_amount := 4
@export var vacuum_radius := 25
@export var radius := 100
@export var freeze := 25

var firing := false
var vacuuming := false

func _ready():
	fire_timer.timeout.connect(_blast)

func _input(event):
	if event.is_action_pressed('primary'):
		firing = true
		fire_timer.start()
		_blast()
	elif event.is_action_released('primary'):
		firing = false
		fire_timer.stop()
	elif event.is_action_pressed('secondary'):
		print_debug('vacuum')
		vacuuming = true
		vacuum_started.emit()
	elif event.is_action_released('secondary'):
		print_debug('vacuum stopped')
		vacuuming = false
		vacuum_stopped.emit()

func _blast():
	if not firing:
		return
	fired.emit(get_global_mouse_position())
	
