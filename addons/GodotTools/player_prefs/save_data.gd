class_name SaveData
extends Resource

@export var time_saved: float
@export var data: String
@export var name: String

func _init(data: String = "") -> void:
	time_saved = Time.get_unix_time_from_system()
	self.data = data

func _to_string() -> String:
	return Serializer.serialize(self)
	
static func deserialize(stringified: String, obj: Object = null) -> SaveData:
	return Serializer.deserialize(stringified, obj)

static func load(path: String) -> SaveData:
	var fa := FileAccess.open(path, FileAccess.READ)
	if not fa:
		printerr("Unable to open save at %s - %s" % [path, FileAccess.get_open_error()])
		return

	var stringified := fa.get_as_text()
	return deserialize(stringified)

func save(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.WRITE)
	if not fa:
		printerr("Unable to open save at %s - %s" % [path, FileAccess.get_open_error()])
		return
	fa.store_string(to_string())

static func remove(path: String) -> void:
	var err := DirAccess.remove_absolute(path)
	if err:
		printerr("Unable to remove save at %s - %s" % [path, err])
