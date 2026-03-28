extends Control
class_name AbilityUI

@onready var border = $Border
@onready var icon = $Icon

func update(d: AbilityData):
	icon.texture = d.icon
