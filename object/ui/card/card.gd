extends Control
class_name Card

signal added(data: Resource)
signal declined()

@onready var icon = $IconSprite
@onready var type = $Type
@onready var title = $Title
@onready var description = $Description
@onready var add_button = $Add

var data: Resource

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	icon.texture = data.icon
	type.text = 'ABILITY' if data is AbilityData else 'BLASTER'
	title.text = data.resource_name
	description.text = type.text + ': ' + title.text

func _on_add_pressed() -> void:
	added.emit(data)

func _on_decline_pressed() -> void:
	declined.emit()
