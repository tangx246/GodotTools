extends PlayerPrefsLineEdit

const KEY: String = "max_fps"
const DEFAULT_VAL: int = 360

func _apply(text: String) -> Variant:
	var text_int: int = int(text)
	print("Setting max FPS to %s" % text_int)
	Engine.max_fps = text_int
	return text_int

func _get_key() -> StringName:
	return KEY

func _get_default_value() -> Variant:
	return DEFAULT_VAL
