class_name MultiprocessEnabledOption
extends PlayerPrefsCheckButton

const MULTIPROCESS_ENABLED_KEY: StringName = "multiprocess_enabled"
const DEFAULT_VAL: bool = true

func _get_key() -> StringName:
	return MULTIPROCESS_ENABLED_KEY

func _get_default_val() -> bool:
	return DEFAULT_VAL

static func get_value() -> bool:
	return PlayerPrefs.get_value(MULTIPROCESS_ENABLED_KEY, DEFAULT_VAL)