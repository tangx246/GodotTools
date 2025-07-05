@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("MultiplayerSynchronizerWorkaround", "MultiplayerSynchronizer", preload("multiplayer_synchronizer_workaround.gd"), preload("icon.svg"))
	var super_multiplayer_synchronizer = preload("super_multiplayer_synchronizer.gd")
	add_autoload_singleton("SuperMultiplayerSynchronizer", super_multiplayer_synchronizer.resource_path)

func _exit_tree():
	remove_custom_type("MultiplayerSynchronizerWorkaround")
	remove_autoload_singleton("SuperMultiplayerSynchronizer")
