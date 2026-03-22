extends BaseLoot
class_name Gold

signal collected(gold: Gold)

func _collect():
	Sound.play(Sound.Effect.COIN)
	collected.emit(self)
	queue_free()
