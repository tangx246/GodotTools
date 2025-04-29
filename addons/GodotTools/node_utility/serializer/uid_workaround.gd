# Workaround for https://github.com/godotengine/godot/issues/75617#issuecomment-2640078921
class_name UIDWorkaround

static var uid_cache: Dictionary[String, int] = {}
static func _static_init() -> void:
	var f := FileAccess.open("res://.godot/uid_cache.bin", FileAccess.READ)
	var count := f.get_32()
	for i in count:
		var id := f.get_64()
		var leng = f.get_32()
		var buffer := f.get_buffer(leng)
		uid_cache[buffer.get_string_from_ascii()] = id

static func get_resource_uid(path: String) -> int:
	return uid_cache[path]
