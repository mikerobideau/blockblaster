extends Target
class_name EnemyHoming

func _ready():
	super()
	speed = 100
	fire_timer.start()

func _physics_process(delta: float):
	var direction = (ship.global_position - global_position).normalized()
	global_position += direction * speed * delta
	var target_angle = direction.angle() + sprite_forward_offset
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
