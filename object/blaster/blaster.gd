extends Node2D
class_name Blaster

signal fired(position: Vector2)
signal vacuum_started()
signal vacuum_stopped()
signal ability1_fired()

@onready var fire_timer = $FireTimer
@onready var ultimate_timer = $UltimateTimer
@onready var crosshair = $Crosshair

@export var default_damage_amount := 3
@export var default_damage_radius := 10
@export var speed := 1500
@export var vacuum_radius := 25
@export var freeze := 25
@export var ultimate: Ultimate
@export var ultimate_duration = 5
@export var ultimate_damage_amount := 10
@export var ultimate_damage_radius = 250
@export var ability1: Cooldown

var damage_amount: int
var damage_radius: int
var firing := false
var vacuuming := false

func _ready():
	_reset_to_default_damage()
	fire_timer.timeout.connect(_blast)
	ultimate_timer.wait_time = ultimate_duration
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
	elif event.is_action_pressed('ability1'):
		_ability1()
		
func set_ultimate(ultimate: Ultimate):
	self.ultimate = ultimate

func set_ability1(ability: Cooldown):
	ability1 = ability

func _blast():
	if not firing:
		return
	fired.emit(get_global_mouse_position())
	
func _ultimate():
	if ultimate.fully_charged():
		print_debug('ultimate')
		ultimate_timer.start()
		damage_amount = ultimate_damage_amount
		damage_radius = ultimate_damage_radius
		
func _ultimate_complete():
	_reset_to_default_damage()
	ultimate.reset_charge()
		
func _reset_to_default_damage():
	damage_amount = default_damage_amount
	damage_radius = default_damage_radius
	
func _ability1():
	ability1_fired.emit(get_global_mouse_position())
	ability1.reset_cooldown()
