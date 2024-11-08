@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AudioStreamPlayer3DSpawner", "Node3D", preload("AudioStreamPlayer3DSpawner.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("AudioStreamPlayer3DSpawner")
