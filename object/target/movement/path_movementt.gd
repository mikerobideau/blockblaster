extends MovementData
class_name PathMovement

enum Type {
	STRAIGHT_ACROSS
}

@export var type: Type

func get_direction(pos: Vector2, center_x: float) -> Vector2:
	match type:
		Type.STRAIGHT_ACROSS:
			print_debug('straight across')
			return Vector2.RIGHT if _is_in_left_hemisphere(pos, center_x) else Vector2.LEFT
		_:
			print_debug('movement path not found')
			return Vector2.ZERO
