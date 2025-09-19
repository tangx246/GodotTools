class_name ControlWindowContainer
extends PanelContainer

var _is_dragging = false
var _drag_offset = Vector2()

signal focused

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			focused.emit()
			_is_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
		else:
			_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		global_position = get_global_mouse_position() - _drag_offset
