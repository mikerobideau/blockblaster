extends Node
class_name WaveGenerator

var meteor_shower = preload("res://resource/enemy_group/meteor_shower.tres")
var linear_ships = preload("res://resource/enemy_group/linear_ships.tres")
var triple_homing = preload("res://resource/enemy_group/triple_homing.tres")
var patrol = preload("res://resource/enemy_group/patrol.tres")
var popup_ships = preload("res://resource/enemy_group/popup_ships.tres")

func generate_calm_wave():
	var wave = WaveData.new()
	wave.resource_name = 'meteor shower'
	wave.enemy_groups.append(meteor_shower)
	return wave
	
func generate_attack_wave():
	var wave = WaveData.new()
	wave.resource_name = 'attack'
	wave.enemy_groups.append(meteor_shower)
	wave.wait_interval = 1
	return wave
