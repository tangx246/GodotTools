class_name SteamSignalingClient
extends SignalingClient

var rtc_mp: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var ws = self
var current_lobby_id: int = -1
var is_hosting: bool = false

func _ready() -> void:
	Signals.safe_connect(self, Steam.lobby_created, _lobby_created)
	Signals.safe_connect(self, Steam.lobby_joined, _lobby_joined)
	Signals.safe_connect(self, Steam.lobby_kicked, _lobby_kicked)
	Signals.safe_connect(self, Steam.lobby_match_list, _on_lobby_list_received)

func _exit_tree() -> void:
	if current_lobby_id != -1:
		Steam.leaveLobby(current_lobby_id)
	stop()

## This is the entry point to this whole class
func start(url: String, _lobby: String = "", _mesh: bool = true, _autojoin: bool = true) -> void:
	if not _autojoin:
		refresh_room_list()
	elif _lobby.is_empty():
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 64)
	else:
		Steam.joinLobby(int(_lobby))

func _lobby_created(result: int, lobby_id: int) -> void:
	if result != Steam.RESULT_OK:
		printerr("Failed to create lobby: %d" % result)
		return
		
	is_hosting = true

func _lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	current_lobby_id = lobby_id
	var error: Error
	if is_hosting:
		print("Creating Steam host peer")
		error = rtc_mp.create_host(0)
	else:
		var lobby_owner: int = Steam.getLobbyOwner(lobby_id)
		print("Creating Steam client peer to lobby: %s, owned by %s" % [lobby_id, lobby_owner])
		error = rtc_mp.create_client(lobby_owner, 0)
	if error != Error.OK:
		printerr("Error creating client: %s" % error)
	
	get_tree().get_multiplayer().multiplayer_peer = rtc_mp

	connected.emit(Steam.getSteamID(), false)
	lobby_joined.emit(str(lobby_id))

func _lobby_kicked(lobby_id: int, admin_id: int, due_to_disconnect: int) -> void:
	stop()	

func seal_lobby() -> void:
	pass

func refresh_room_list() -> Error:
	Steam.requestLobbyList()
	return 0

func _on_lobby_list_received(lobbies: Array) -> void:
	var lobby_list: Dictionary = {}
	for lobby in lobbies:
		lobby_list[str(lobby)] = true
	room_list_received.emit(lobby_list)

func stop() -> void:
	is_hosting = false
	var default_peer: MultiplayerPeer = MultiplayerAPI.create_default_interface().multiplayer_peer
	get_tree().get_multiplayer().multiplayer_peer = default_peer
	rtc_mp.close()
	disconnected.emit()

## Faking self.ws.get_ready_state()
func get_ready_state() -> WebSocketPeer.State:
	return WebSocketPeer.State.STATE_CLOSED
