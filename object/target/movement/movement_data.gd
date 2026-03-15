extends Resource
class_name MovementData

@export var speed := 500

func get_direction(pos: Vector2, center_x: float) -> Vector2:
	return Vector2.ZERO

func _is_in_left_hemisphere(pos: Vector2, center_x: float) -> bool:
	return pos.x < center_x
	
func _is_in_right_hemisphere(pos: Vector2, center_x: float) -> bool:
	return pos.x > center_x
