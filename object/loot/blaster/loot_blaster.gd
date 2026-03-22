extends BaseLoot
class_name LootBlaster

@export var data: BlasterData

signal collected(loot_blaster: LootBlaster)

func _collect():
	Sound.play(Sound.Effect.COIN)
	collected.emit(self)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	pass #blaster must be manually picked up
