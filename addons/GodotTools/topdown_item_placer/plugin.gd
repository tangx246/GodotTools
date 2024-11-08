@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("TopdownItemPlacer", "Node3D", preload("topdown_item_placer.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("TopdownItemPlacer")
