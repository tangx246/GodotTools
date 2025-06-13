extends MenuOptionButton

const KEY: String = "Fullscreen"

func _get_key() -> String:
	return KEY

func _get_current_setting() -> int:
	return DisplayServer.window_get_mode()

## Maps id to option
func _get_options() -> Dictionary[int, MenuOption]:
	return {
		DisplayServer.WINDOW_MODE_WINDOWED: MenuOption.new(0, DisplayServer.WINDOW_MODE_WINDOWED, "Windowed"),
		DisplayServer.WINDOW_MODE_FULLSCREEN: MenuOption.new(1, DisplayServer.WINDOW_MODE_FULLSCREEN, "Borderless Fullscreen"),
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: MenuOption.new(2, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, "Exclusive Fullscreen")
	}

func _set_option(id: int):
	DisplayServer.window_set_mode(id)
