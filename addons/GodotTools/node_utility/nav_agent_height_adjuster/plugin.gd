@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("NavAgentHeightAdjuster", "Node3D", preload("nav_agent_height_adjuster.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("NavAgentHeightAdjuster")
