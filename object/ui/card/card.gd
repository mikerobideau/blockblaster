extends Control
class_name Card

signal added(data: BlasterData)
signal declined()

@onready var icon = $IconSprite
@onready var type = $Type
@onready var title = $Title
@onready var description = $Description
@onready var add_button = $Add

var data: BlasterData

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	icon.texture = data.icon
	type.text = 'BLASTER'
	title.text = data.name
	description.text = 'Damage: ' + str(data.damage) + ', Radius: ' + str(data.radius)

func _on_add_pressed() -> void:
	added.emit(data)

func _on_decline_pressed() -> void:
	declined.emit()
