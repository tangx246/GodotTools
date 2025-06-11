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
				var res_path: String = obj.get_script().resource_path
				# See _init_uid_cache()
				var resource_uid: int = UIDWorkaround.get_resource_uid(res_path)
				if resource_uid == -1:
					printerr("Could not find Resource UID for %s" % res_path)
				save_data[name] = ResourceUID.id_to_text(resource_uid)
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

static func deserialize(data: String, obj: Object = null) -> Object:
	var parsed: Dictionary = JSON.parse_string(data)
	return _deserialize(parsed, obj)
	
static func _deserialize(parsed: Dictionary, obj: Object = null) -> Object:
	var parsed_script: String = parsed["script"]
	var script: Script = load(parsed_script)
	parsed.erase("script")

	if obj == null:
		obj = script.new()
	assert(is_instance_of(obj, script), "%s must be an instance of %s" % [obj.get_script(), script])
	
	for key: String in parsed:
		var value: Variant = _parse_object(parsed[key], obj.get(key))
		if typeof(value) in [TYPE_ARRAY, TYPE_DICTIONARY]:
			obj.get(key).assign(value)
		else:
			obj.set(key, value)
		
	return obj

static func _parse_object(value: Variant, possible_source_obj: Variant) -> Variant:
	# Possibly an object. Start parsing
	if value is String:
		var json: JSON = JSON.new()
		var parse_success: Error = json.parse(value)
		if parse_success == OK:
			var possible_object: Variant = json.data
			if possible_object != null and possible_object is Dictionary and possible_object.has("script"):
				value = _deserialize(possible_object, possible_source_obj)
	elif value is Array:
		for i in range(value.size()):
			var src_obj: Variant = possible_source_obj[i] if possible_source_obj.size() > i else null
			value[i] = _parse_object(value[i], src_obj)
	elif value is Dictionary:
		for key in value:
			value[key] = _parse_object(value[key], possible_source_obj.get(key))
			
	return value
