extends Target
class_name Meteor

@onready var sprite = $Sprite2D
@onready var hit_box = $HitBox

var size: Vector2

func _ready():
	rotation = randf() * TAU
	_resize()
	_start()

func _resize():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		sprite.scale = size / texture_size
	
	var shape = hit_box.shape as CircleShape2D
	if shape:
		shape.radius = size.x / 2
