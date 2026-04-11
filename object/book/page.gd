extends Control
class_name Page

@onready var subviewport = $Picture/SubViewport
@onready var sketch = $Picture/Sketch
@onready var chapter = $ChapterContainer/TypewriterText

func _ready():
	set_process(true)
	process_mode = Node.PROCESS_MODE_ALWAYS	
	var size: Vector2 = Vector2(subviewport.size)
	sketch.material.set_shader_parameter("reveal_progress", 0.0)
	sketch.material.set_shader_parameter("texel_size", Vector2(1.0, 1.0) / size)
	await get_tree().create_timer(0.5).timeout
	chapter.start_typing()
	await get_tree().create_timer(0.5).timeout
	await chapter.finished_typing
	_reveal_sketch()
	
func _reveal_sketch():
	var tween = create_tween()
	tween.tween_property(sketch.material, "shader_parameter/reveal_progress", 1.0, 1.0)
