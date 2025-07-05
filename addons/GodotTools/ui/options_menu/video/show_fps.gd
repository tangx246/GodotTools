extends CheckButton

const SHOW_FPS_KEY = "show_fps"

func _ready() -> void:
	button_pressed = PlayerPrefs.get_value(SHOW_FPS_KEY, false)
	pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	PlayerPrefs.set_value(SHOW_FPS_KEY, button_pressed)
