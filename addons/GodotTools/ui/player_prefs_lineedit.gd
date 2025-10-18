class_name PlayerPrefsLineEdit
extends LineEdit

func _ready() -> void:
	Signals.safe_connect(self, text_submitted, _on_text_changed, CONNECT_DEFERRED)
	var saved: int = PlayerPrefs.get_value(_get_key(), _get_default_value())
	text = str(saved)
	_on_text_changed(str(saved))

func _on_text_changed(_new_text: String):
	PlayerPrefs.set_value(_get_key(), _apply(text))

## Applies the value. Returns the new valie to be saved in PlayerPrefs
func _apply(text: String) -> Variant:
	assert(false, "Unimplemented")
	return null

func _get_key() -> StringName:
	assert(false, "Unimplemented")
	return ""

func _get_default_value() -> Variant:
	assert(false, "Unimplemented")
	return ""
