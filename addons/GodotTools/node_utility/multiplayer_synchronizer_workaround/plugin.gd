@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("MultiplayerSynchronizerWorkaround", "MultiplayerSynchronizer", preload("multiplayer_synchronizer_workaround.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("MultiplayerSynchronizerWorkaround")
