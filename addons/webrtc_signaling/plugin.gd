@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("PlayerSpawner", "MultiplayerSpawner", preload("game/player_spawner.gd"), preload("icon.svg"))
	add_autoload_singleton("MultiplayerSceneSwitcher", "res://addons/webrtc_signaling/game/scene_switcher.gd")

func _exit_tree():
	remove_custom_type("PlayerSpawner")
	remove_autoload_singleton("MultiplayerSceneSwitcher")
