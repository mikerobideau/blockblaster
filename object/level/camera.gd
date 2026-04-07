extends Camera2D

@export var ship: Ship
@export var follow_speed := 6.0

func _process(delta):
	if ship == null:
		return
		
	global_position = ship.global_position
