extends Control
class_name Blaster

signal fired()
signal vacuum_started()
signal vacuum_stopped()
signal ability1_fired()

var EnergyScene = preload("res://object/blaster/energy/energy.tscn")
var pea_shooter = preload("res://resource/blaster/pea_shooter.tres")

@onready var fire_timer = $FireTimer
@onready var ultimate_timer = $UltimateTimer
@onready var crosshair = $Crosshair
@onready var icon = $Icon

@export var data: BlasterData
@export var vacuum_radius := 25
@export var ultimate: Ultimate
@export var ability1: Cooldown

var firing := false
var ultimate_active := false
var ship: Ship

func _ready():
	update(pea_shooter)
	fire_timer.timeout.connect(_blast)
	ultimate_timer.timeout.connect(_on_ultimate_complete)

func update(d: BlasterData):
	data = d
	icon.texture = d.icon

func set_ship(s: Ship):
	ship = s

func set_ultimate(u: Ultimate):
	ultimate = u

func set_ability1(a: Cooldown):
	ability1 = a

func _input(event):
	if event.is_action_pressed('primary'):
		firing = true
		fire_timer.start()
		_blast()
	elif event.is_action_released('primary'):
		firing = false
		fire_timer.stop()
	elif event.is_action_pressed('secondary'):
		vacuum_started.emit()
	elif event.is_action_released('secondary'):
		vacuum_stopped.emit()
	elif event.is_action_pressed('ultimate'):
		_ultimate()
	elif event.is_action_pressed('ability1'):
		ability1_fired.emit(get_global_mouse_position())
		ability1.reset_cooldown()

	
func _blast():
	if not firing:
		return
	var energy = EnergyScene.instantiate()
	var dir = (get_global_mouse_position() - ship.emitter.global_position).normalized()
	energy.global_position = ship.emitter.global_position
	energy.direction = dir
	energy.damage = data.ultimate_damage if ultimate_active else data.damage
	energy.radius = data.ultimate_radius if ultimate_active else data.radius
	energy.speed = data.speed
	energy.set_texture(data.energy_icon)
	get_tree().current_scene.add_child(energy)

func _ultimate():
	if ultimate.fully_charged():
		ultimate_active = true
		ultimate_timer.wait_time = data.ultimate_duration
		ultimate_timer.start()

func _on_ultimate_complete():
	ultimate_active = false
	ultimate.reset_charge()
