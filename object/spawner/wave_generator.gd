extends Node
class_name WaveGenerator

var meteor_shower = preload("res://resource/enemy_group/meteor_shower.tres")

func generate_calm_wave():
	var wave = WaveData.new()
	wave.enemy_groups.append(meteor_shower)
	return wave
