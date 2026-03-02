extends RefCounted
class_name LootFactory

var GoldScene = preload('res://object/loot/gold/gold.tscn')

func create_gold() -> Gold:
	return GoldScene.instantiate()
