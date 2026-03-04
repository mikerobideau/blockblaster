extends Control
class_name Cooldown

@onready var timer = $Timer
@onready var label = $Label

@export var cooldown_time := 5
@export var damage_radius := 500
@export var damage_amount := 10

var cooldown_time_remaining

func _ready():
	timer.wait_time = 1
	reset_cooldown()
	timer.timeout.connect(_on_cooldown_tick)

func _on_cooldown_tick():
	cooldown_time_remaining = clamp(cooldown_time_remaining - 1, 0, cooldown_time)
	_update_label()
	if cooldown_time_remaining == 0:
		_on_cooldown_complete()

func reset_cooldown():
	cooldown_time_remaining = cooldown_time
	_update_label()
	timer.start()

func _on_cooldown_complete():
	timer.stop()

func _update_label():
	if cooldown_time_remaining == 0:
		label.text = 'Ready'
		return
	label.text = str(cooldown_time_remaining)
	
func available():
	cooldown_time_remaining == 0
