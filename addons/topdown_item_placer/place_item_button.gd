class_name PlacedItemButton
extends Button

signal pressed_item(item: PlacedItem)
@export var item : PlacedItem

func _ready():
	pressed.connect(func(): pressed_item.emit(item))
