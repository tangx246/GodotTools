extends MenuApplyHSlider

const UI_SCALE_KEY = "ui_scale"

func _get_key() -> String:
	return UI_SCALE_KEY

func _apply_setting(value: float) -> void:
	get_tree().root.content_scale_factor = value
