@tool
extends EditorPlugin

func _enter_tree():
	var module = preload("control_window_manager.gd")
	add_autoload_singleton("ControlWindowManager", module.resource_path)

func _exit_tree():
	remove_autoload_singleton("ControlWindowManager")
