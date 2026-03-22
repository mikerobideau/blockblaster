extends RefCounted
class_name BaseDatabase

var data: Dictionary = {}

static func load_directory(path: String) -> Dictionary:
	var _data: Dictionary = {}
	var dir = DirAccess.open(path)
	
	if not dir:
		push_error("Base_database: could not open path: " + path)
		return _data
	
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		if file.ends_with(".tres"):
			var full_path = path + file
			var res = load(full_path)
			
			if res == null:
				push_warning("Base_database: failed to load: " + full_path)
			else:
				var key = file.get_basename()
				if _data.has(key):
					push_warning("Base_database: duplicate key '" + key + "' skipping: " + full_path)
				else:
					_data[key] = res
		
		file = dir.get_next()
	
	dir.list_dir_end()
	return _data
	
func find_all() -> Array[Resource]:
	var result: Array[Resource] = []
	result.assign(data.values())
	return result

func find_random() -> Resource:
	var values = data.values()
	return values[randi() % values.size()]
	
func find_by_type(type: int):
	return find_by('type', type)

func find_by(property: String, value: Variant) -> Resource:
	var matches = data.values().filter(func(d): return d.get(property) == value)
	if matches.is_empty():
		push_warning("BaseDatabase: find_by found no matches for " + property + " = " + str(value))
		return null
	if matches.size() > 1:
		push_warning("BaseDatabase: find_by found multiple matches for " + property + " = " + str(value))
	return matches[0]
