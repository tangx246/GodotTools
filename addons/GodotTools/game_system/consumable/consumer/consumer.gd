class_name Consumer
extends Node

## If true, items are consumed immediately. Otherwise, items are consumed only when finished
@export var item_consumed_immediately: bool = false

func start_consumption(consumable: Consumable, finished: Callable) -> void:
	printerr("Unimplemented")
