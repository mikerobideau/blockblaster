extends Area2D
class_name LootBlaster

signal picked_up(loot_blaster: LootBlaster)

@export var data: BlasterData

func _ready():
	body_entered.connect(_on_body_entered)
		
func _on_body_entered(body: Node):
	if body is Ship:
		picked_up.emit(self)
