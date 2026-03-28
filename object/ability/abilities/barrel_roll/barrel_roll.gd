extends Node
class_name BarrelRoll

signal started()
signal finished()

var active := false
var cooldown_remaining := 0.0
var data: AbilityData

@onready var timer = $Timer

func setup(d: AbilityData):
	data = d
	timer.wait_time = d.cooldown
	timer.timeout.connect(_on_cooldown_complete)
	
func activate(direction: Vector2):
	if active or cooldown_remaining > 0:
		return
	active = true
	started.emit()
	timer.start()
	
func _on_cooldown_complete():
	active = false
	cooldown_remaining = 0
	finished.emit()
