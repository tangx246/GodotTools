@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Daynight", "Node3D", preload("daynight.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("Daynight")
