extends Control
class_name BlasterUI

@onready var border = $Border
@onready var icon = $Icon

func update(d: BlasterData):
	icon.texture = d.icon
