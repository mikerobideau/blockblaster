extends RefCounted
class_name BaseDatabase

static func load_directory(path: String) -> Dictionary:
	var data: Dictionary = {}
	var dir = DirAccess.open(path)
	
	if not dir:
		push_error("BaseDatabase: could not open path: " + path)
		return data
	
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		if file.ends_with(".tres"):
			var full_path = path + file
			var res = load(full_path)
			
			if res == null:
				push_warning("BaseDatabase: failed to load: " + full_path)
			else:
				var key = file.get_basename()
				if data.has(key):
					push_warning("BaseDatabase: duplicate key '" + key + "' skipping: " + full_path)
				else:
					data[key] = res
		
		file = dir.get_next()
	
	dir.list_dir_end()
	return data
