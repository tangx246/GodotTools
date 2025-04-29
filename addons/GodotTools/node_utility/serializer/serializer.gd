class_name Serializer

# Workaround for https://github.com/godotengine/godot/issues/75617#issuecomment-2640078921
static var uid_cache: Dictionary[String, int] = {}
static func _init_uid_cache():
	if not uid_cache.is_empty():
		return
	var f := FileAccess.open("res://.godot/uid_cache.bin", FileAccess.READ)
	var count := f.get_32()
	for i in count:
		var id := f.get_64()
		var leng = f.get_32()
		var buffer := f.get_buffer(leng)
		uid_cache[buffer.get_string_from_ascii()] = id

static func serialize(obj: Object, use_uid: bool = true) -> String:
	var save_data: Dictionary[String, Variant] = {}
	var property_list: Array[Dictionary] = obj.get_property_list()
	for properties: Dictionary in property_list:
		if properties["usage"] & PROPERTY_USAGE_EDITOR == 0:
			continue
		
		var name: String = properties["name"]
		
		if name == "script":
			if use_uid:
				_init_uid_cache()
				var res_path: String = obj.get_script().resource_path
				# See _init_uid_cache()
				#var resource_uid: int = ResourceLoader.get_resource_uid(res_path)
				var resource_uid: int = uid_cache[res_path]
				if resource_uid == -1:
					printerr("Could not find Resource UID for %s" % res_path)
				save_data[name] = ResourceUID.id_to_text(resource_uid)
				print("Saved: %s %s" % [save_data[name], ResourceLoader.get_resource_uid(obj.get_script().resource_path)])
			else:
				save_data[name] = obj.get_script().resource_path
		else:
			save_data[name] = obj.get(name)
	
	# Remove some extra built-in stuff
	for key: String in [
		"resource_path", 
		"resource_name", 
		"resource_local_to_scene",
		"auto_translate_mode",
		"editor_description",
		"physics_interpolation_mode",
		"process_mode",
		"process_physics_priority",
		"process_priority",
		"process_thread_group"]:
		save_data.erase(key)
	
	return JSON.stringify(save_data, "", true, true)

static func deserialize(data: String) -> Object:
	var parsed: Dictionary = JSON.parse_string(data)
	return _deserialize(parsed)
	
static func _deserialize(parsed: Dictionary) -> Object:
	var parsed_script: String = parsed["script"]
	var script: Script = load(parsed_script)
	parsed.erase("script")

	var obj = script.new()
	
	for key: String in parsed:
		var value: Variant = _parse_object(parsed[key])
		if typeof(value) in [TYPE_ARRAY, TYPE_DICTIONARY]:
			obj.get(key).assign(value)
		else:
			obj.set(key, value)
		
	return obj

static func _parse_object(value: Variant) -> Variant:
	# Possibly an object. Start parsing
	if value is String:
		var json: JSON = JSON.new()
		var parse_success: Error = json.parse(value)
		if parse_success == OK:
			var possible_object: Variant = json.data
			if possible_object != null and possible_object is Dictionary and possible_object.has("script"):
				value = _deserialize(possible_object)
	elif value is Array:
		for i in range(value.size()):
			value[i] = _parse_object(value[i])
	elif value is Dictionary:
		for key in value:
			value[key] = _parse_object(value[key])
			
	return value
