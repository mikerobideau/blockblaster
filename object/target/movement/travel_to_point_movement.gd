extends MovementData
class_name TravelToPointMovement

enum TravelState {
	APPROACH,
	FIRE,
	EXIT
}

@export var waypoint: Vector2
@export var wait_to_exit := 1

var travel_state := TravelState.APPROACH

func get_direction(pos: Vector2, center: Vector2):
	return (waypoint -pos).normalized()
