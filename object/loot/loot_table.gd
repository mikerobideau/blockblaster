extends Resource
class_name LootTable

@export var rolls := 1
@export var drop_chance := 0.5 #probability that a roll will produce loot
@export var entries: Array[LootData] = []
@export var guaranteed_entry: LootData
