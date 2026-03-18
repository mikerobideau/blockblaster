extends RefCounted
class_name TargetDatabase

var data: Dictionary = {}

func load_all():
	data = BaseDatabase.load_directory("res://resource/target/")
	print_debug('Loaded ' + str(data.values().size()) + ' target resources')

func find_random():
	var values = data.values()
	return values[randi() % values.size()]

func find_by_type(type: Target.TargetType) -> TargetData:
	var matches = data.values().filter(func(d): return d.type == type)
	if matches.size() > 1:
		print_debug('TargetDatabase found multiple matches for type ' + str(type))
		push_warning('TargetDatabase found multiple matches for type ' + str(type))
	if matches.is_empty():
		print_debug('TargetDatabase found no matches for type ' + str(type))
		push_warning('TargetDatabase found no matches for type ' + str(type))
		return null

	return matches[0]
