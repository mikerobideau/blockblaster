extends Control
class_name Blaster

var pea_shooter = preload("res://resource/blaster/pea_shooter.tres")

signal fired(position: Vector2)
signal vacuum_started()
signal vacuum_stopped()
signal ability1_fired()

@onready var fire_timer = $FireTimer
@onready var ultimate_timer = $UltimateTimer
@onready var crosshair = $Crosshair
@onready var icon = $Icon

@export var data: BlasterData
@export var vacuum_radius := 25
@export var freeze := 25
@export var ultimate: Ultimate
@export var ability1: Cooldown

var default_blaster = pea_shooter
var damage: int
var radius: int
var speed: int
var firing := false
var vacuuming := false

func _ready():
	update(default_blaster)
	fire_timer.timeout.connect(_blast)
	ultimate_timer.timeout.connect(_ultimate_complete)
	
func update(d: BlasterData):
	data = d
	icon.texture = d.icon
	ultimate_timer.wait_time = d.ultimate_duration
	_reset_to_default_damage()

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
		ultimate_timer.start()
		damage = data.ultimate_damage
		radius = data.ultimate_radius
		
func _ultimate_complete():
	_reset_to_default_damage()
	ultimate.reset_charge()
		
func _reset_to_default_damage():
	damage = data.damage
	radius = data.radius
	speed = data.speed
	
func _ability1():
	ability1_fired.emit(get_global_mouse_position())
	ability1.reset_cooldown()
