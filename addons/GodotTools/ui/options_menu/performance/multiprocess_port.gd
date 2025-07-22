class_name MultiprocessPortOption
extends PlayerPrefsLineEdit

const MULTIPROCESS_PORT_KEY: StringName = "MultiprocessPort"
const DEFAULT_VAL: int = 25843

## Applies the value. Returns the new valie to be saved in PlayerPrefs
func _apply(text: String) -> Variant:
	return clampi(int(text), 1025, 65535)

func _get_key() -> StringName:
	return MULTIPROCESS_PORT_KEY

func _get_default_value() -> Variant:
	return DEFAULT_VAL

static func get_value() -> int:
	return clampi(PlayerPrefs.get_value(MULTIPROCESS_PORT_KEY, DEFAULT_VAL), 1025, 65535)