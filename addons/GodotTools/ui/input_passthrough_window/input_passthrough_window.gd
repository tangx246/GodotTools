class_name EmbeddedInputPassthroughWindow
extends Window

var mouse_in_window: bool = false
var children_windows: Array[Window] = []

func _ready() -> void:
	Signals.safe_connect(self, get_parent().visibility_changed, _on_parent_visibility_changed)
	_on_parent_visibility_changed()

	Signals.safe_connect(self, mouse_entered, _on_mouse_entered)
	Signals.safe_connect(self, mouse_exited, _on_mouse_exited)

	children_windows.assign(find_children("", "Window", true, false))

func _on_mouse_entered() -> void:
	if _should_shift_focus():
		_reset_focus()

	mouse_in_window = true

func _on_mouse_exited() -> void:
	mouse_in_window = false

func _should_shift_focus() -> bool:
	# Don't muck with focus for drag events or if there are any modal children windows focused
	return not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _is_any_children_window_focused()

func _unhandled_input(event: InputEvent) -> void:
	if _should_shift_focus():
		_unfocus()
		get_parent().get_viewport().push_input(event)

func _unfocus() -> void:
	unfocusable = true
	grab_focus()
	unfocusable = false

func _reset_focus() -> void:
	unfocusable = false
	grab_focus()

func _is_any_children_window_focused() -> bool:
	for window in children_windows:
		if window.has_focus():
			return true

	return false

func _on_parent_visibility_changed() -> void: 
	visible = (get_parent() as Control).is_visible_in_tree()
