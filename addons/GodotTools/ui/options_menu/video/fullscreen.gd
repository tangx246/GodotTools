extends OptionButton

const KEY: String = "Fullscreen"

func _enter_tree() -> void:
	item_selected.connect(_on_item_selected)
	
	var current_window_mode: int = DisplayServer.window_get_mode()
	if current_window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		select(0)
	elif current_window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		select(1)
	elif current_window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		select(2)
		
	var saved: int = PlayerPrefs.get_value(KEY, -1)
	if saved != -1:
		select(saved)
		_on_item_selected(saved)

func _exit_tree() -> void:
	if item_selected.is_connected(_on_item_selected):
		item_selected.disconnect(_on_item_selected)

func _on_item_selected(item: int):
	if item == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif item == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif item == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		
	PlayerPrefs.set_value(KEY, item)
