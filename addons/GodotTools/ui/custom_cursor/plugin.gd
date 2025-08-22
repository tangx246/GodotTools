@tool
extends EditorPlugin

func _enter_tree():
	var module = preload("custom_cursor.tscn")
	add_autoload_singleton("CustomCursor", module.resource_path)

func _exit_tree():
	remove_autoload_singleton("CustomCursor")
