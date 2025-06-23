@tool
extends EditorPlugin

func _enter_tree():
	var steaminit = preload("steam_init.gd")
	add_autoload_singleton("SteamInit", steaminit.resource_path)

func _exit_tree():
	remove_autoload_singleton("SteamInit")
