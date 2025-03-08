@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("PlayerSpawner", "MultiplayerSpawner", preload("game/player_spawner.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("PlayerSpawner")
