@tool
extends EditorPlugin

const pluginName : String = "NavigationServerQueries"

func _enter_tree():
	var nav_server_queries = preload("navigation_server_queries.gd")
	add_autoload_singleton(pluginName, nav_server_queries.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
