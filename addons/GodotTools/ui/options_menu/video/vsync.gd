extends OptionButton

const KEY: String = "VSync"

func _enter_tree() -> void:
	item_selected.connect(_on_item_selected)
	
	var current_vsync: int = DisplayServer.window_get_vsync_mode()
	if current_vsync == DisplayServer.VSYNC_DISABLED:
		select(0)
	elif current_vsync == DisplayServer.VSYNC_ENABLED:
		select(1)
	elif current_vsync == DisplayServer.VSYNC_ADAPTIVE:
		select(2)
	elif current_vsync == DisplayServer.VSYNC_MAILBOX:
		select(3)
		
	var saved: int = PlayerPrefs.get_value(KEY, -1)
	if saved != -1:
		select(saved)
		_on_item_selected(saved)

func _exit_tree() -> void:
	if item_selected.is_connected(_on_item_selected):
		item_selected.disconnect(_on_item_selected)

func _on_item_selected(item: int):
	if item == 0:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif item == 1:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif item == 2:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif item == 3:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
		
	PlayerPrefs.set_value(KEY, item)
