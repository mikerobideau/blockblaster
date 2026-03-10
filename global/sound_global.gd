extends Node
class_name SoundGlobal

var sounds = {
	'enemy_hit': preload('res://asset/sound/effect/319200__18hiltc__pixel-game-beep.wav')
}

var player := AudioStreamPlayer.new()

func _ready():
	add_child(player)

func play(id: String):
	player.stream = sounds[id]
	player.play()
