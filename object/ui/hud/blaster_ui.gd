extends Control
class_name BlasterUI

@onready var icon = $Icon

func update(d: BlasterData):
	icon.texture = d.icon
