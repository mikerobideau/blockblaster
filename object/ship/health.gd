extends Control
class_name Health

signal game_over()

@onready var label = $Label
@onready var max_health := 10

var health: int

func _ready():
	health = max_health
	_update_label()

func heal(amount: int):
	health = clamp(health + amount, 0, max_health)
	_update_label()
	
func take_damage(amount: int):
	health = clamp(health - amount, 0, max_health)
	_check_game_over()
	_update_label()
	
func _check_game_over():
	if health <= 0:
		game_over.emit()

func _update_label():
	label.text = str(health)
