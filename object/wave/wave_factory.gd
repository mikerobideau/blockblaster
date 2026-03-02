extends RefCounted
class_name WaveFactory

var WaveScene = preload("res://object/wave/wave.tscn")

func create() -> Wave:
	return WaveScene.instantiate()
