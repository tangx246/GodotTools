class_name InputActionButton
extends Button

@export var action : StringName

func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)
