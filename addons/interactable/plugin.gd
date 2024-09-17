@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Interactor", "Node3D", preload("interactor.gd"), preload("icon.svg"))
	add_custom_type("Interactable", "Node3D", preload("interactable.gd"), preload("icon.svg"))
	add_input_map()

func _exit_tree():
	remove_custom_type("Interactor")
	remove_custom_type("Interactable")

func add_input_map():
	var input_to_events = {
		"input/interact": KEY_F
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
