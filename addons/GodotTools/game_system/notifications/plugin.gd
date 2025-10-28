@tool
extends EditorPlugin

const pluginName = "Notifications"

func _enter_tree():
	var singleton = preload("notifications.gd")
	add_autoload_singleton(pluginName, singleton.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
