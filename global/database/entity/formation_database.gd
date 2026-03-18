extends RefCounted
class_name FormationDatabase

var data: Dictionary = {}

func load_all():
	print_debug('Loading all formations...')
	data = BaseDatabase.load_directory("res://resource/formation/")
	print_debug('formations loaded: ')
	print_debug(str(data))
	
func find_random():
	var values = data.values()
	return values[randi() % values.size()]
