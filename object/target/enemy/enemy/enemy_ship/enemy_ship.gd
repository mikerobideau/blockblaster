extends Target
class_name EnemyShip

func _physics_process(delta: float):
	#if not ship:
	#	return
	#var target_angle = (ship.global_position - global_position).angle() + sprite_forward_offset
	#rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

	global_position += direction * speed * delta
