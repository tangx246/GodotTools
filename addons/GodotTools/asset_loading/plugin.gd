@tool
extends EditorPlugin

const pluginName : String = "LoadAssets"

func _enter_tree():
	var singleton = preload("load_assets.gd")
	add_autoload_singleton(pluginName, singleton.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
