@tool
extends EditorPlugin

const pluginName = "NetworkSync"

func _enter_tree():
	var singleton = preload("network_sync.gd")
	add_autoload_singleton(pluginName, singleton.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
