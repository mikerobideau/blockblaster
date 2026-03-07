extends Control
class_name Ultimate

@onready var pct_label = $Pct
@onready var timer = $TickTimer

@export var full_charge := 1000
@export var charge_tick = 5

var current_charge := 0

func _ready():
	_update_label()
	timer.timeout.connect(_on_timeout)
	
func _on_timeout():
	if current_charge < full_charge:
		charge(charge_tick)
	
func charge(amount: int):
	current_charge = clamp(current_charge + amount, 0, full_charge)
	_update_label()

func _update_label():
	var pct = int(round(float(current_charge) / float(full_charge) * 100))
	pct_label.text = str(pct) + '%'

func fully_charged() -> bool:
	return current_charge == full_charge
	
func reset_charge():
	current_charge = 0
	_update_label()
	
