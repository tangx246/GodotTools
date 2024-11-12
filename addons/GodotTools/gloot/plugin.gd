@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("LootTableFiller", "Node3D", preload("loot_table/loot_table_filler.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("LootTableFiller")
