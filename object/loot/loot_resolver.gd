extends Node
class_name LootResolver

var GoldScene = preload("res://object/loot/gold/gold.tscn")
var HealthScene = preload("res://object/loot/health/loot_health.tscn")

const RARITY_WEIGHT: Dictionary = {
	LootData.Rarity.COMMON: 1.0,
	LootData.Rarity.UNCOMMON: 0.4,
	LootData.Rarity.RARE: 0.15,
	LootData.Rarity.LEGENDARY: 0.04
}

func resolve(
	table: LootTable,
	spawn_pos: Vector2,
	parent: Node2D,
	blaster: Blaster,
	ship: Ship
):
	if table == null:
		return
	
	if table.guaranteed_entry != null:
		_spawn_entry(table.guaranteed_entry, spawn_pos, parent, blaster, ship)
		
	#Procedural rolls
	for i in range(table.rolls):
		if randf() > table.drop_chance:
			continue
		var entry = _roll(table.entries)
		if entry:
			_spawn_entry(entry, spawn_pos, parent, blaster, ship)
			
func _roll(entries: Array[LootData]) -> LootData:
	if entries.is_empty():
		return null
	var total_weight := 0.0
	for e in entries:
			total_weight += _effective_weight(e)
			
	var roll = randf() * total_weight
	var cumulative := 0.0
	for e in entries:
		cumulative += _effective_weight(e)
		if roll <= cumulative:
			return e
			
	return entries.back()
		
func _effective_weight(entry: LootData) -> float:
	return RARITY_WEIGHT.get(entry.rarity, 1.0)
	
func _spawn_entry(
	entry: LootData,
	pos: Vector2,
	parent: Node2D,
	blaster: Blaster,
	ship: Ship
):
	match entry.loot_type:
		LootData.Type.GOLD:
			var count = randi_range(entry.gold_min, entry.gold_max)
			for i in range(count):
				var gold = GoldScene.instantiate()
				gold.global_position = pos
				gold.set_blaster(blaster)
				gold.set_ship(ship)
				gold.collected.connect(func(g): _on_gold_collected(g, parent))
				parent.add_child(gold)
		LootData.Type.HEALTH:
			var count = randi_range(entry.health_min, entry.health_max)
			for i in range(count):
				var health = HealthScene.instantiate()
				health.global_position = pos
				health.set_blaster(blaster)
				health.set_ship(ship)
				health.collected.connect(func(g): _on_health_collected(g, parent))
				parent.add_child(health)
				
func _on_gold_collected(gold: Gold, parent: Node2D):
	if parent.has_signal("gold_collected"):
		parent.emit_signal("gold_collected", gold)
		
func _on_health_collected(health: LootHealth, parent: Node2D):
	if parent.has_signal("health_collected"):
		parent.emit_signal("health_collected", health)
		
