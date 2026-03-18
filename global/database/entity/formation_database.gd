extends RefCounted
class_name FormationDatabase

var data: Dictionary = {}

func load_all():
	data = BaseDatabase.load_directory("res://resource/formation/")
	
func find_random():
	var values = data.values()
	return values[randi() % values.size()]
