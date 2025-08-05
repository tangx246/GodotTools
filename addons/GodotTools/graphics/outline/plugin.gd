@tool
extends EditorPlugin

const pluginName = "OutlineShader"

func _enter_tree():
	var plugin = preload("outline_shader.tscn")
	add_autoload_singleton(pluginName, plugin.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
