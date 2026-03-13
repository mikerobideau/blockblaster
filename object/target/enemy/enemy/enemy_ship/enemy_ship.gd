extends Target
class_name EnemyShip

var data = preload("res://resource/target/enemy_ship.tres")

func _ready():
	super()
	direction = Vector2.RIGHT if _is_in_left_hemisphere() else Vector2.LEFT
	rotation = _flip_horizontal(direction)

func _physics_process(delta: float):
	global_position += direction * speed * delta
	
