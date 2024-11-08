@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("PlayerSpawner", "MultiplayerSpawner", preload("game/player_spawner.gd"), preload("icon.svg"))
	add_autoload_singleton("MultiplayerSceneSwitcher", preload("game/scene_switcher.gd").new().get_script().get_path())

func _exit_tree():
	remove_custom_type("PlayerSpawner")
	remove_autoload_singleton("MultiplayerSceneSwitcher")
