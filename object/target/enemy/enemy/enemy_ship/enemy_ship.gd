extends Target
class_name EnemyShip

func _ready():
	super()
	direction = Vector2.RIGHT if _is_in_left_hemisphere() else Vector2.LEFT
	rotation = _flip_horizontal(direction)

func _physics_process(delta: float):
	global_position += direction * speed * delta
	
