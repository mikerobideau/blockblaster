extends Control
class_name Health

signal game_over()

@onready var label = $Label

var health := 3

func _ready():
	_update_label()

func heal(amount: int):
	health = clamp(health + amount, 0, 100)
	_update_label()
	
func take_damage(amount: int):
	health = clamp(health - amount, 0, 100)
	_check_game_over()
	_update_label()
	
func _check_game_over():
	if health <= 0:
		game_over.emit()

func _update_label():
	label.text = str(health)
