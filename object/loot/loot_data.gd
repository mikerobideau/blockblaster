extends Resource
class_name LootData

enum Type { GOLD, HEALTH, BLASTER, ABILITY, ULTIMATE }
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }

@export var loot_type := Type.GOLD 
@export var gold_min := 1
@export var gold_max := 5
@export var health_min := 1
@export var health_max := 5
@export var blaster_data: BlasterData
@export var rarity := Rarity.COMMON
