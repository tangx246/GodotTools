class_name PlayerPrefsCheckButton
extends CheckButton

func _ready() -> void:
	button_pressed = PlayerPrefs.get_value(_get_key(), _get_default_val())
	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	PlayerPrefs.set_value(_get_key(), button_pressed)

func _get_key() -> StringName:
	assert(false, "Unimplemented")
	return ""

func _get_default_val() -> bool:
	return false
