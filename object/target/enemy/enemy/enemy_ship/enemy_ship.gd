extends Target
class_name EnemyShip

func _ready():
	super()
	rotation = _flip_horizontal(direction)

func _physics_process(delta: float):
	global_position += direction * speed * delta
	
