@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("NavigationCharBody3D", "CharacterBody3D", preload("navigation_characterbody3d.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("NavigationCharBody3D")
