class_name ItemProvider
extends Node

var item_count : int = 0:
	set(value):
		item_count = value
		item_count_changed.emit(value)
signal item_count_changed(new_count: int)

func has_item() -> bool:
	return item_count > 0

## Returns ammo actually used
func use_item(_count : int) -> int:
	printerr("Unimplemented")
	return 0
