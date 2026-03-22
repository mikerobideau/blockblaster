extends BaseLoot
class_name LootHealth

signal collected(health: LootHealth)

@onready var sprite = $Sprite2D
@onready var hit_box = $HitBox

func _collect():
	Sound.play(Sound.Effect.COIN)
	collected.emit(self)
	queue_free()
