@tool
extends EditorPlugin

const pluginName : String = "PlayerPrefs"

func _enter_tree():
	var playerPrefs = preload("player_prefs.gd")
	add_autoload_singleton(pluginName, playerPrefs.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
