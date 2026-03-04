extends Node2D
class_name Blaster

signal fired(position: Vector2)
signal vacuum_started()
signal vacuum_stopped()

@onready var fire_timer = $FireTimer
@onready var ultimate_timer = $UltimateTimer
@onready var crosshair = $Crosshair

@export var default_damage_amount := 4
@export var default_damage_radius := 100
@export var vacuum_radius := 25
@export var freeze := 25
@export var ultimate: Ultimate
@export var ultimate_damage_amount := 10
@export var ultimate_damage_radius = 500

var damage_amount: int
var damage_radius: int
var firing := false
var vacuuming := false

func _ready():
	_reset_to_default_damage()
	fire_timer.timeout.connect(_blast)
	ultimate_timer.timeout.connect(_ultimate_complete)

func _input(event):
	if event.is_action_pressed('primary'):
		firing = true
		fire_timer.start()
		_blast()
	elif event.is_action_released('primary'):
		firing = false
		fire_timer.stop()
	elif event.is_action_pressed('secondary'):
		vacuuming = true
		vacuum_started.emit()
	elif event.is_action_released('secondary'):
		vacuuming = false
		vacuum_stopped.emit()
	elif event.is_action_pressed('ultimate'):
		_ultimate()
		
func set_ultimate(ultimate: Ultimate):
	self.ultimate = ultimate

func _blast():
	if not firing:
		return
	fired.emit(get_global_mouse_position())
	
func _ultimate():
	if ultimate.fully_charged():
		ultimate_timer.start()
		damage_amount = ultimate_damage_amount
		damage_radius = ultimate_damage_radius
		
func _ultimate_complete():
	print_debug('ultimate complete')
	_reset_to_default_damage()
		
func _reset_to_default_damage():
	damage_amount = default_damage_amount
	damage_radius = default_damage_radius
	
