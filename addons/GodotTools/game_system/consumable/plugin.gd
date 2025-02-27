@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Consumable", "Resource", preload("consumable.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("Consumable")
