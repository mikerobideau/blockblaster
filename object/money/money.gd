extends Control
class_name Money

@onready var label = $Label

var money := 0

func add(amount: int):
	money += amount
	_update_label()
	
func _update_label():
	label.text = '$' + str(money)
