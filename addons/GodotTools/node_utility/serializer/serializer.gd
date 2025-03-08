class_name Serializer

static func serialize(obj: Object, use_uid: bool = true) -> String:
	var save_data: Dictionary[String, Variant] = {}
	var property_list: Array[Dictionary] = obj.get_property_list()
	for properties: Dictionary in property_list:
		if properties["usage"] & PROPERTY_USAGE_EDITOR == 0:
			continue
		
		var name: String = properties["name"]
		
		if name == "script":
			if use_uid:
				# We save the String representation because Godot loses precision info... On an int...
				save_data[name] = str(ResourceLoader.get_resource_uid(obj.get_script().resource_path))
			else:
				save_data[name] = obj.get_script().resource_path
		else:
			save_data[name] = obj.get(name)
	
	# Remove some extra stuff
	for key: String in ["resource_path", "resource_name", "resource_local_to_scene"]:
		save_data.erase(key)
	
	return JSON.stringify(save_data, "", true, true)

static func deserialize(data: String) -> Object:
	var parsed: Dictionary = JSON.parse_string(data)
	return _deserialize(parsed)
	
static func _deserialize(parsed: Dictionary) -> Object:
	var parsed_script: String = parsed["script"]
	var path_int: int = int(parsed_script)
	var path: String
	if path_int:
		path = ResourceUID.id_to_text(path_int)
	else:
		path = parsed_script
	var script: Script = load(path)
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
