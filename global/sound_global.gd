extends Node
class_name SoundGlobal

enum Effect {
	ENEMY_HIT,
	ENEMY_DEFEATED,
	BLASTER_FIRED,
	COIN
}

var sounds = {
	Effect.ENEMY_HIT: preload("res://global/hitHurt (2).wav"),
	Effect.ENEMY_DEFEATED: preload("res://global/explosion (4).wav"),
	Effect.BLASTER_FIRED: preload("res://global/laserShoot(04).wav"),
	Effect.COIN: preload("res://global/pickupCoin (2).wav")
}

var player := AudioStreamPlayer.new()

func _ready():
	add_child(player)

func play(id: Effect):
	player.stream = sounds[id]
	player.play()
