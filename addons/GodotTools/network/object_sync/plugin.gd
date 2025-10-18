@tool
extends EditorPlugin

const pluginName = "ObjectSync"

func _enter_tree():
	var singleton = preload("object_sync.gd")
	add_autoload_singleton(pluginName, singleton.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
