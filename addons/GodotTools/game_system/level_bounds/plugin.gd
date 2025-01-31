@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("LevelBounds", "Node3D", preload("level_bounds.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("LevelBounds")
