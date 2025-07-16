class_name MenuOptionButton
extends OptionButton

signal setting_changed

func _get_key() -> String:
	assert(false, "Unimplemented")
	return ""

func _get_current_setting() -> int:
	assert(false, "Unimplemented")
	return -1

## Maps id to option
func _get_options() -> Dictionary[int, MenuOption]:
	assert(false, "Unimplemented")
	return {}

func _set_option(id: int):
	assert(false, "Unimplemented")

class MenuOption extends RefCounted:
	var index: int
	var id: int
	var text: String

	func _init(index: int, id: int, text: String):
		self.index = index
		self.id = id
		self.text = text

func _enter_tree() -> void:
	clear()
	var options: Dictionary[int, MenuOption] = _get_options()
	var sorted_menu_options: Array = options.values()
	sorted_menu_options.sort_custom(func(a: MenuOption, b: MenuOption): return b.index > a.index)
	for menu_option in sorted_menu_options:
		add_item(menu_option.text, menu_option.id)

	item_selected.connect(_on_item_selected)
	
	var current_setting: int = _get_current_setting()
	if not options.has(current_setting):
		push_warning("Options %s does not contain %s" % [JSON.stringify(options), current_setting])
		return
	select(options[current_setting].index)

	var saved: int = PlayerPrefs.get_value(_get_key(), -1)
	if saved != -1:
		select(saved)
		_on_item_selected(saved)

func _exit_tree() -> void:
	if item_selected.is_connected(_on_item_selected):
		item_selected.disconnect(_on_item_selected)

func _on_item_selected(index: int):
	var id: int = get_item_id(index)
	_set_option(id)
	setting_changed.emit()
	PlayerPrefs.set_value(_get_key(), index)
