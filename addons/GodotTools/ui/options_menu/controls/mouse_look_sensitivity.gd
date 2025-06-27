class_name MouseLookSensitivity
extends MenuApplyHSlider

const MOUSE_LOOK_KEY = "mouse_look_sensitivity"

func _get_key() -> String:
	return MOUSE_LOOK_KEY

func _apply_setting(value: float) -> void:
	pass
