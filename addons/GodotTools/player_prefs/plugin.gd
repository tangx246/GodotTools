@tool
extends EditorPlugin

const pluginName : String = "PlayerPrefs"
const saveGamesName: String = "SaveGames"

func _enter_tree():
	var playerPrefs = preload("player_prefs.gd")
	add_autoload_singleton(pluginName, playerPrefs.resource_path)
	var saveGames = preload("save_games.gd")
	add_autoload_singleton(saveGamesName, saveGames.resource_path)

func _exit_tree():
	remove_autoload_singleton(pluginName)
	remove_autoload_singleton(saveGamesName)
