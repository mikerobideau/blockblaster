extends Label
class_name TypewriterText

signal finished_typing()

@onready var timer = $Timer

@export var chars_per_second = 10.0

var typing := false

func _ready():
	visible_characters = 0
	
func start_typing():
	typing = true
	timer.timeout.connect(_type)
	timer.wait_time = 1.0 / chars_per_second
	timer.start()
	
func _type():
	if not typing:
		return

	visible_characters += 1
	if visible_characters >= text.length():
		typing = false
		timer.stop()
		finished_typing.emit()
