extends Camera2D

@export var ship: Ship
func _process(delta):
	if ship == null:
		return

	global_position.x = ship.global_position.x
