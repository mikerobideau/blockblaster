extends RefCounted
class_name SpawnGroupDatabase

static var data: Array[SpawnGroupData] = [
	preload("res://resource/spawn_group/basic.tres") as SpawnGroupData
]

func find_random() -> SpawnGroupData:
	#return data.pick_random() as SpawnGroupData
	var basic = preload("res://resource/spawn_group/basic.tres")
	print_debug(basic)
	print_debug(basic.get_script())
	print_debug(basic is SpawnGroupData)
	return basic as SpawnGroupData
