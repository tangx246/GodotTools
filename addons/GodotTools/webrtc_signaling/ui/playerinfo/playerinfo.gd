class_name PlayerInfo
extends Node

@onready var client: WebsocketSignalingClient = %Client

const Player = preload("uid://cuytk13ncwovs")
var players: Dictionary[int, Player] = {}

signal player_info_updated

const GROUP: StringName = "PlayerInfo"

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return

	Signals.safe_connect(self, multiplayer.connected_to_server, _connected_to_server)
	Signals.safe_connect(self, multiplayer.peer_connected, _peer_connected)
	Signals.safe_connect(self, client.disconnected, _disconnected)

func _disconnected() -> void:
	players = {}
	player_info_updated.emit()

func _ready() -> void:
	add_to_group(GROUP)

func _connected_to_server() -> void:
	_submit_player_info()

func _peer_connected(id: int) -> void:
	if is_multiplayer_authority():
		_submit_player_info()

func _submit_player_info() -> void:
	_submit_name_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, get_player_name(), get_steam_id())

func get_player_name() -> String:
	if is_multiplayer_authority():
		return "server"
	else:
		var steam = SteamInit.get_steam()
		if steam:
			return steam.getPersonaName()
		return "player"

func get_steam_id() -> String:
	var steam = SteamInit.get_steam()
	if steam:
		return str(steam.getSteamID())
	else:
		return ""

@rpc("any_peer", "call_local", "reliable")
func _submit_name_rpc(name: String, steam_id: String):
	var remote_id: int = multiplayer.get_remote_sender_id()
	if not players.has(remote_id):
		players[remote_id] = Player.new()
		players[remote_id].id = remote_id

	players[remote_id].steam_id = steam_id
	players[remote_id].name = name

	_sync_names.rpc(JSON.stringify(players, "", false, true))

@rpc("authority", "call_local", "reliable")
func _sync_names(data: String):
	var parsed: Dictionary = JSON.parse_string(data)
	var new_players: Dictionary[int, Player] = {}
	for key in parsed:
		var player: Player = Player.deserialize(parsed[key])
		new_players[int(key)] = player
		Signals.safe_connect(self, player.updated, player_info_updated.emit)

	players.assign(new_players)

	player_info_updated.emit()

func get_players() -> Dictionary[int, Player]:
	if players.is_empty():
		var player: Player = Player.new()
		Signals.safe_connect(self, player.updated, player_info_updated.emit)
		player.id = multiplayer.get_unique_id()
		player.name = get_player_name()
		player.steam_id = get_steam_id()
		players[player.id] = player

	return players
