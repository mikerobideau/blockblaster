extends Target
class_name Crystal

func _ready():
	speed = 100
	rotation = randf() * TAU
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
