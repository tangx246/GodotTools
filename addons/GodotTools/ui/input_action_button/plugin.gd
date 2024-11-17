@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("InputActionButton", "Node3D", preload("input_action_button.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("InputActionButton")
