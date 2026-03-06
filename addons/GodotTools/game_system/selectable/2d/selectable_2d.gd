class_name Selectable2D
extends Area2D

@export var root: Node
signal selected(root: Node)

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(root)
			viewport.set_input_as_handled()
