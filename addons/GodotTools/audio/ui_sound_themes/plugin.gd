@tool
extends EditorPlugin

const pluginName : String = "UISoundHijacker"

func _enter_tree():
	var loaded = preload("ui_sound_theme.tscn")
	add_autoload_singleton(pluginName, loaded.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
