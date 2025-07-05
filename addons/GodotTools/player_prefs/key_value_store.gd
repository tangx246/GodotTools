class_name KeyValueStore
extends Node

var values : Dictionary = {}
var savePath : String = ""

signal value_changed(key: String)

func _init(savePath: String):
	self.savePath = savePath
	assert(not savePath.is_empty(), "savePath must be set")
	
	if not FileAccess.file_exists(savePath):
		return # Error! We don't have a save to load.
		
	var save_game = FileAccess.open(savePath, FileAccess.READ)
	var json_string = save_game.get_as_text()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	# Get the data from the JSON object
	var node_data = json.get_data()

	values = node_data
 
func save():
	var save_game = FileAccess.open(savePath, FileAccess.WRITE)

	# Call the node's save function.
	var node_data = values

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data, "", true, true)

	# Store the save dictionary as a new line in the save file.
	save_game.store_string(json_string)
	
func set_value(key: String, value: Variant, save: bool = true):
	values[key] = value
	value_changed.emit(key)
	
	if save:
		save()
	
func get_value(key: String, default: Variant = null) -> Variant:
	if !has_key(key):
		return default
	else:
		return values[key]

func has_key(key: String) -> bool:
	return values.has(key)
	
func delete_key(key: String, save: bool = true):
	values.erase(key)
	value_changed.emit(key)

	if save:
		save()
