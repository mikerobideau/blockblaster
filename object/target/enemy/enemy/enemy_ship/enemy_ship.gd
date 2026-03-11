extends Target
class_name EnemyShip

func _physics_process(delta: float):
	global_position += direction * speed * delta
