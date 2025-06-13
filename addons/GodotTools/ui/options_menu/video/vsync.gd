extends MenuOptionButton

const KEY: String = "VSync"

func _get_key() -> String:
	return KEY

func _get_current_setting() -> int:
	return DisplayServer.window_get_vsync_mode()

## Maps id to option
func _get_options() -> Dictionary[int, MenuOption]:
	return {
		DisplayServer.VSYNC_DISABLED: MenuOption.new(0, DisplayServer.VSYNC_DISABLED, "Disabled"),
		DisplayServer.VSYNC_ENABLED: MenuOption.new(1, DisplayServer.VSYNC_ENABLED, "Enabled"),
		DisplayServer.VSYNC_ADAPTIVE: MenuOption.new(2, DisplayServer.VSYNC_ADAPTIVE, "Adaptive"),
		DisplayServer.VSYNC_MAILBOX: MenuOption.new(3, DisplayServer.VSYNC_MAILBOX, "Mailbox")
	}

func _set_option(id: int):
	DisplayServer.window_set_vsync_mode(id)
