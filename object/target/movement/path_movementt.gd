extends MovementData
class_name PathMovement

enum Type {
	STRAIGHT_ACROSS,
	STRAIGHT_DOWN,
	DRIFT,
	S_ACROSS
	#Circle
	#Spiral
	#Ski,
	#lawnmower
}

@export var type: Type

func get_direction(pos: Vector2, center: Vector2) -> Vector2:
	match type:
		Type.STRAIGHT_ACROSS:
			return Vector2.RIGHT if _is_in_left_hemisphere(pos, center.x) else Vector2.LEFT
		Type.STRAIGHT_DOWN:
			return Vector2.DOWN
		Type.DRIFT:
			var center_offset = 500
			var offset = Vector2(
				randf_range(-center_offset, center_offset),
				randf_range(-center_offset, center_offset)
			)
			var dest = center + offset
			var to_dest = dest - pos
			var direction = to_dest.normalized()
			return direction
		Type.S_ACROSS:
			return Vector2.RIGHT if _is_in_left_hemisphere(pos, center.x) else Vector2.LEFT
		_:
			print_debug('movement path not found')
			return Vector2.ZERO
