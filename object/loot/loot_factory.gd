extends RefCounted
class_name LootFactory

var GoldScene = preload('res://object/loot/gold/gold.tscn')
var LootBlasterScene = preload("res://object/loot/blaster/loot_blaster.tscn")

var pea_shooter = preload("res://resource/blaster/pea_shooter.tres")

func create_gold() -> Gold:
	return GoldScene.instantiate()

func create_loot_blaster() -> LootBlaster:
	var blaster = LootBlasterScene.instantiate()
	blaster.data = pea_shooter
	return blaster
