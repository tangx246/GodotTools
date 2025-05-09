@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("FPSController", "CharacterBody3D", preload("FPS/Player.gd"), preload("icon.svg"))
	add_fps_controller_input_map()


func _exit_tree():
	remove_custom_type("FPSController")

class JoyEvent:
	var axis: JoyAxis
	var axis_val: float
	
	func _init(axis: JoyAxis, axis_val: float):
		self.axis = axis
		self.axis_val = axis_val

func add_fps_controller_input_map():
	var input_to_events = {
		"input/Move Forward": [KEY_W],
		"input/Move Backward": [KEY_S],
		"input/Strafe Left": [KEY_A],
		"input/Strafe Right": [KEY_D],
		"input/Look Up": [JoyEvent.new(JOY_AXIS_RIGHT_Y, -1)],
		"input/Look Down": [JoyEvent.new(JOY_AXIS_RIGHT_Y, 1)],
		"input/Look Left": [JoyEvent.new(JOY_AXIS_RIGHT_X, -1)],
		"input/Look Right": [JoyEvent.new(JOY_AXIS_RIGHT_X, 1)],
		"input/Jump": [KEY_SPACE],
		"input/Crouch": [KEY_C],
		"input/Prone": [KEY_X],
		"input/Lean Left": [KEY_Q],
		"input/Lean Right": [KEY_E],
		"input/Sprint": [KEY_SHIFT],
	}
	
	for input in input_to_events:
		var events = input_to_events[input]
		var processed_events = []
		for event in events:
			if event is Key:
				var input_event_key = InputEventKey.new()
				input_event_key.physical_keycode = event
				processed_events.append(input_event_key)
			elif event is JoyEvent:
				var input_event_joy = InputEventJoypadMotion.new()
				input_event_joy.axis = event.axis
				input_event_joy.axis_value = event.axis_val
				processed_events.append(input_event_joy)
			else:
				printerr("Unhandled event %s" % event)
				
		if not ProjectSettings.has_setting(input):
			ProjectSettings.set_setting(input,
			{
				"deadzone": 0.5,
				"events": processed_events
			})

	ProjectSettings.save()
