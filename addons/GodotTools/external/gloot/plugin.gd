@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("LootTableFiller", "Node3D", preload("loot_table/loot_table_filler.gd"), preload("icon.svg"))
	var loaded = preload("dragable_workaround.gd")
	add_autoload_singleton("DragableWorkaround", loaded.resource_path)

func _exit_tree():
	remove_custom_type("LootTableFiller")
	remove_autoload_singleton("DragableWorkaround")
