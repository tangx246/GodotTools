class_name SaveData

@export var time_saved: float
@export var data: String

func _init(data: String = "") -> void:
	time_saved = Time.get_unix_time_from_system()
	self.data = data

func _to_string() -> String:
	return Serializer.serialize(self)
	
static func deserialize(stringified: String, obj: Object = null) -> SaveData:
	return Serializer.deserialize(stringified, obj)
