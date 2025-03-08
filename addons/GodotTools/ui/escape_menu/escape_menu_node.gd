extends Node

@onready var menu: PopupPanel = %EscapeMenu

var prev_mouse_mode: Input.MouseMode
func _ready() -> void:
	prev_mouse_mode = Input.mouse_mode

func _enter_tree() -> void:
	await ready
	menu.visibility_changed.connect(_on_visibility_changed)
	
func _exit_tree() -> void:
	if menu.visibility_changed.is_connected(_on_visibility_changed):
		menu.visibility_changed.disconnect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if menu.visible:
		prev_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		Input.mouse_mode = prev_mouse_mode

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		menu.popup()
