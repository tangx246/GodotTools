extends HSlider

signal text_changed(val: String)

const UI_SCALE_KEY = "ui_scale"

func _enter_tree() -> void:
	Signals.safe_connect(self, value_changed, func(val): text_changed.emit(str(val)))
	value = PlayerPrefs.get_value(UI_SCALE_KEY, 1.0)
	apply()

func apply():
	get_tree().root.content_scale_factor = value
	PlayerPrefs.set_value(UI_SCALE_KEY, value)
