@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("FPSController", "CharacterBody3D", preload("FPS/Player.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("FPSController")
