@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("FPSController", "CharacterBody3D", preload("FPS/Player.gd"), preload("icon.svg"))
	add_fps_controller_input_map()


func _exit_tree():
	remove_custom_type("FPSController")

func add_fps_controller_input_map():
	var input_to_events = {
		"input/Move Forward": KEY_W,
		"input/Move Backward": KEY_S,
		"input/Strafe Left": KEY_A,
		"input/Strafe Right": KEY_D,
		"input/Jump": KEY_SPACE,
		"input/Crouch": KEY_C,
		"input/Prone": KEY_X
	}
	
	for input in input_to_events:
		var input_event_key = InputEventKey.new()
		input_event_key.physical_keycode = input_to_events[input]
		if not ProjectSettings.has_setting(input):
			ProjectSettings.set_setting(input,
			{
				"deadzone": 0.5,
				"events": [input_event_key]
			})

	ProjectSettings.save()
