extends LineEdit

const KEY: String = "max_fps"

func _enter_tree() -> void:
	text_submitted.connect(_on_text_changed, CONNECT_DEFERRED)
	var saved: int = PlayerPrefs.get_value(KEY, 360)
	text = str(saved)

func _exit_tree() -> void:
	if text_submitted.is_connected(_on_text_changed):
		text_submitted.disconnect(_on_text_changed)

func _on_text_changed(_new_text: String):
	var text_int: int = int(text)
	print("Setting max FPS to %s" % text_int)
	Engine.max_fps = text_int
	PlayerPrefs.set_value(KEY, text_int)