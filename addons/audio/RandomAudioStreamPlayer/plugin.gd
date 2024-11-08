@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("RandomAudioStreamPlayer3D", "Node3D", preload("RandomAudioStreamPlayer3D.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("RandomAudioStreamPlayer3D")
