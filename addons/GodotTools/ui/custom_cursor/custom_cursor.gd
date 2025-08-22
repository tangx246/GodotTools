extends Node

@export var default_cursor: Texture
@export var can_drop_cursor: Texture

func _ready() -> void:
	Input.set_custom_mouse_cursor(default_cursor)
	Input.set_custom_mouse_cursor(can_drop_cursor, Input.CursorShape.CURSOR_CAN_DROP)
