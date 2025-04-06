class_name InputPassthroughWindow
extends Window

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_unfocus()
		get_parent().get_viewport().push_input(event)
		_reset_focus()

func _unfocus() -> void:
	unfocusable = true
	grab_focus()

func _reset_focus() -> void:
	unfocusable = false
	grab_focus()

func _on_mouse_entered() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		grab_focus()
