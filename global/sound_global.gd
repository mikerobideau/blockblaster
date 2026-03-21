extends Node
class_name SoundGlobal

enum Effect {
	ENEMY_HIT,
	ENEMY_DEFEATED,
	BLASTER1,
	BLASTER2,
	BLASTER3,
	BLASTER4,
	BLASTER5,
	COIN
}

var sounds = {
	Effect.ENEMY_HIT: preload("res://asset/sound/effect/jsfxr/explosion (10).wav"),
	Effect.ENEMY_DEFEATED: preload("res://asset/sound/effect/jsfxr/explosion (4).wav"),
	Effect.BLASTER1: preload("res://asset/sound/effect/jsfxr/laserShoot (1).wav"),
	Effect.BLASTER2: preload("res://asset/sound/effect/jsfxr/laserShoot (2).wav"),
	Effect.BLASTER3: preload("res://asset/sound/effect/jsfxr/laserShoot (3).wav"),
	Effect.BLASTER4: preload("res://asset/sound/effect/jsfxr/laserShoot (4).wav"),
	Effect.BLASTER5: preload("res://asset/sound/effect/jsfxr/laserShoot (5).wav"),
	Effect.COIN: preload("res://asset/sound/effect/jsfxr/pickupCoin (2).wav")
}

var player := AudioStreamPlayer.new()

func _ready():
	player.volume_db = -20
	add_child(player)

func play(id: Effect):
	player.stream = sounds[id]
	player.play()
