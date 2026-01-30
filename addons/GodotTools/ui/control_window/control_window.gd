## Control that looks like a Window
@tool
class_name ControlWindow
extends CanvasLayer

@export var show_close_button: bool = true
## If true, creates a fullscreen background that blocks input to elements behind this window.
@export var exclusive: bool = false
@export var title: String = "Title":
	set(value):
		var prev = value
		title = value
		if title_label and prev != title:
			title_label.text = title
@onready var close_button: Button = %CloseButton
@onready var title_label: Label = %Title
@onready var title_background: Control = %TitleBackground
var content: Control
var control_window_container: ControlWindowContainer

signal close_requested

func _enter_tree() -> void:
	content = %Content
	control_window_container = %ControlWindowContainer
	if not Engine.is_editor_hint():
		var children = get_children()
		children.erase(control_window_container)
		for child in children:
			child.reparent(content)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not content:
		warnings.push_back("ControlWindow has no Content node. Make sure to use the provided PackedScene")
	return warnings

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if exclusive:
		_create_exclusive_background()

	EmbeddedUI.attach(self, false)
	ControlWindowManager.register(self)

	Signals.safe_connect(self, close_button.pressed, close_requested.emit)
	close_button.visible = show_close_button
	
	title_label.text = title

	title_background.mouse_filter = Control.MOUSE_FILTER_PASS

	Signals.safe_connect(self, control_window_container.focused, _on_container_focused)

func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return
	
	if what == NOTIFICATION_PREDELETE:
		ControlWindowManager.unregister(self)

func _on_container_focused() -> void:
	ControlWindowManager.focused(self)

func _create_exclusive_background() -> void:
	var background = ColorRect.new()
	background.color = Color.TRANSPARENT
	var viewport_size = get_viewport().get_visible_rect().size
	var buffer = viewport_size * 2
	background.size = viewport_size + buffer
	background.position = -buffer / 2 - offset
	background.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(background)
	move_child(background, 0)
