class_name MenuApplyHSlider
extends HSlider

@export var default_value: float = 1.0

func _get_key() -> String:
	assert(false, "Unimplemented")
	return ""

func _apply_setting(value: float) -> void:
	assert(false, "Unimplemented")

func _enter_tree() -> void:
	value = PlayerPrefs.get_value(_get_key(), default_value)
	apply()

func _ready() -> void:
	var label: Label = Label.new()
	value_changed.connect(func(val): label.text = str(val))
	label.text = str(value)
	get_parent().add_child.call_deferred(label)

	var button: Button = Button.new()
	button.text = "Apply"
	button.pressed.connect(apply)
	get_parent().add_child.call_deferred(button)

func apply():
	_apply_setting(value)
	PlayerPrefs.set_value(_get_key(), value)
