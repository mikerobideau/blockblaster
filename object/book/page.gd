extends Node2D
class_name Page

@onready var subviewport = $SubViewport
@onready var mat = $TextureRect.material

func _ready():
	var size = subviewport.size
	mat.set_shader_parameter("texel_size", 1.0 / size)
