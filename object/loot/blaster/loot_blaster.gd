extends BaseLoot
class_name LootBlaster

@export var data: BlasterData

signal collected(loot_blaster: LootBlaster)

func _collect():
	Sound.play(Sound.Effect.COIN)
	collected.emit(self)
	queue_free()
