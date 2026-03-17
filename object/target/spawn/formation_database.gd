extends RefCounted
class_name FormationDatabase

static var data: Array[Formation] = [
	preload("res://resource/formation/basic_formation.tres") as Formation
]

func find_random() -> Formation:
	#return data.pick_random() as Formation
	var basic = preload("res://resource/formation/basic_formation.tres")
	print_debug(basic)
	print_debug(basic.get_script())
	print_debug(basic is Formation)
	return basic as Formation
