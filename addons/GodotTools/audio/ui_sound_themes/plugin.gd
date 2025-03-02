@tool
extends EditorPlugin

const pluginName : String = "UISoundHijacker"

func _enter_tree():
	pass
	#var loaded = preload("ui_sound_theme.tscn")
	#add_autoload_singleton(pluginName, loaded.resource_path)

func _exit_tree():
	pass
	#remove_autoload_singleton(pluginName)
