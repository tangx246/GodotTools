extends Node

var values : Dictionary = {}
const savePath : String = "user://playerprefs.save"

func _init():
	if not FileAccess.file_exists(savePath):
		return # Error! We don't have a save to load.
		
	var save_game = FileAccess.open(savePath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		values = node_data
 
func save():
	var save_game = FileAccess.open(savePath, FileAccess.WRITE)

	# Call the node's save function.
	var node_data = values

	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(node_data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
	
func set_value(key: String, value: Variant, save: bool = true):
	values[key] = value
	
	if save:
		save()
	
func get_value(key: String, default: Variant = null) -> Variant:
	if !has_key(key):
		return default
	else:
		return values[key]

func has_key(key: String) -> bool:
	return values.has(key)
	
func delete_key(key: String):
	values.erase(key)
