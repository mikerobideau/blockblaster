extends Node
class_name SoundGlobal

enum Effect {
	ENEMY_HIT
}

var sounds = {
	Effect.ENEMY_HIT: preload('res://asset/sound/effect/319200__18hiltc__pixel-game-beep.wav')
}

var player := AudioStreamPlayer.new()

func _ready():
	add_child(player)

func play(id: Effect):
	player.stream = sounds[id]
	player.play()
