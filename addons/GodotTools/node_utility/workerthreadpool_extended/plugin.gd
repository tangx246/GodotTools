@tool
extends EditorPlugin

const pluginName = "WorkerThreadPoolExtended"

func _enter_tree():
	var wtpe = preload("workerthreadpool_extended.gd")
	add_autoload_singleton(pluginName, wtpe.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
