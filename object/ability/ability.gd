extends Node
class_name Ability

signal started()
signal finished()

@onready var duration_timer = $DurationTimer
@onready var cooldown_timer = $CooldownTimer

@export var data: AbilityData

var active := false
var ship: Ship

func setup(d: AbilityData, s: Ship):
	data = d
	ship = s
	cooldown_timer.wait_time = d.cooldown
	cooldown_timer.one_shot = true
	duration_timer.wait_time = d.duration
	duration_timer.timeout.connect(_on_duration_complete)

func is_ready():
	var is_ready = !active and cooldown_timer.is_stopped()
	return is_ready

func activate():
	if !is_ready():
		return
	active = true
	if data.disables_cursor:
		ship.blaster.crosshair.visible = false
	started.emit()
	duration_timer.start()
	
func _on_duration_complete():
	duration_timer.stop()
	active = false
	if data.disables_cursor:
		ship.blaster.crosshair.visible = true
	cooldown_timer.start()
	finished.emit()
