extends BaseDatabase
class_name BlasterDatabase

func load_all():
	data = load_directory("res://resource/blaster/")

func find_all_as_loot(rarity: LootData.Rarity = LootData.Rarity.COMMON) -> Array[LootData]:
	var entries: Array[LootData] = []
	for blaster in find_all():
		var entry = LootData.new()
		entry.loot_type = LootData.Type.BLASTER
		entry.blaster_data = blaster
		entry.rarity = rarity
		entries.append(entry)
	return entries

func _collect():
	pass
