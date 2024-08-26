@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("FollowTarget", "Node3D", preload("follow_target.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("FollowTarget")
