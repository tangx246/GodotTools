class_name SaveList
extends Control

@onready var save_game_view: PackedScene = preload("uid://m1iwdhcp8xt5")

signal load_requested(save: SaveData)

func _ready() -> void:
	visibility_changed.connect(_request_refresh)

	Signals.safe_connect(self, SaveGames.save_changed, _request_refresh_rpc)

func _request_refresh() -> void:
	if not visible:
		return
	
	_request_refresh_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)

@rpc("any_peer", "call_local", "reliable")
func _request_refresh_rpc():
	var save_games: Array[SaveData] = SaveGames.get_all_saves()
	_refresh.rpc(JSON.stringify(save_games))

@rpc("authority", "call_local", "reliable")
func _refresh(save_games_stringified: String):
	var save_games_serialized: Array = JSON.parse_string(save_games_stringified)
	var save_games: Array[SaveData] = []
	for serialized: String in save_games_serialized:
		save_games.append(SaveData.deserialize(serialized))

	for child in get_children():
		child.queue_free()
		
	for i in range(save_games.size()):
		var save_game: SaveData = save_games[i]
		var save_game_view_instance: Control = save_game_view.instantiate()
		_set_view(save_game_view_instance, i, save_game)
		add_child(save_game_view_instance)

func _set_view(save_game_view_instance: Control, index: int, save_game: SaveData) -> void:
	var name_label: Label = save_game_view_instance.get_node(^"%Name")
	var when_label: Label = save_game_view_instance.get_node(^"%When")
	var load_button: Button = save_game_view_instance.get_node(^"%Load")
	var delete_button: Button = save_game_view_instance.get_node(^"%Delete")

	name_label.text = save_game.name
	var time_zone_bias_seconds: int = Time.get_time_zone_from_system()["bias"] * 60
	when_label.text = Time.get_datetime_string_from_unix_time(int(save_game.time_saved) + time_zone_bias_seconds, true)
	load_button.pressed.connect(func():
		_load_game_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, index)
		get_window().hide()
	)
	delete_button.pressed.connect(func():
		_delete_save_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, index)
	)

@rpc("any_peer", "call_local", "reliable")
func _delete_save_rpc(index: int) -> void:
	SaveGames.delete(index)

@rpc("any_peer", "call_local", "reliable")
func _load_game_rpc(index: int) -> void:
	load_requested.emit(SaveGames.get_all_saves()[index])
