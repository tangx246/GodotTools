extends Control

@onready var client: WebsocketSignalingClient = %Client
@onready var host: LineEdit = %Host
@onready var room: LineEdit = %RoomSecret
@onready var mesh: CheckBox = %Mesh
@onready var multiprocess: Multiprocess = %Multiprocess
@onready var multiprocess_checkbox: CheckBox = %MultiprocessCheckbox
@onready var multiplayerUi: Control = %VBoxContainer
@onready var multiplayerUiRoot: Control = $"%VBoxContainer/.."
@onready var main: Node = $"%VBoxContainer/../.."
@onready var room_list: ItemList = %RoomList

func _ready() -> void:
	_connect_signals(client)

	multiplayer.connected_to_server.connect(_mp_server_connected)
	multiplayer.connection_failed.connect(_mp_server_disconnect)
	multiplayer.server_disconnected.connect(_mp_server_disconnect)
	multiplayer.peer_connected.connect(_mp_peer_connected)
	multiplayer.peer_disconnected.connect(_mp_peer_disconnected)
	
	#get_tree().get_multiplayer().connected_to_server.connect(_mp_server_connected)
	#get_tree().get_multiplayer().connection_failed.connect(_mp_server_disconnect)
	#get_tree().get_multiplayer().server_disconnected.connect(_mp_server_disconnect)
	#get_tree().get_multiplayer().peer_connected.connect(_mp_peer_connected)
	#get_tree().get_multiplayer().peer_disconnected.connect(_mp_peer_disconnected)

	room_list.item_activated.connect(_on_room_list_activated)

func _connect_signals(client: WebsocketSignalingClient):
	client.lobby_joined.connect(_lobby_joined)
	client.lobby_sealed.connect(_lobby_sealed)
	client.connected.connect(_connected)
	client.disconnected.connect(_disconnected)
	client.room_list_received.connect(_room_list_received)

func _mp_server_connected() -> void:
	_log("[Multiplayer] Server connected (I am %d)" % multiplayer.get_unique_id())


func _mp_server_disconnect() -> void:
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())

func _mp_peer_connected(id: int) -> void:
	_log("[Multiplayer] Peer %d connected" % id)


func _mp_peer_disconnected(id: int) -> void:
	_log("[Multiplayer] Peer %d disconnected" % id)
	if id == MultiplayerPeer.TARGET_PEER_SERVER:
		_on_stop_pressed()

func _connected(id: int, use_mesh: bool) -> void:
	_log("[Signaling] Server connected with ID: %d. Mesh: %s" % [id, use_mesh])


func _disconnected() -> void:
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])
	multiplayerUiRoot.visible = true

func _lobby_joined(lobby: String) -> void:
	_log("[Signaling] Joined lobby %s" % lobby)


func _lobby_sealed() -> void:
	_log("[Signaling] Lobby has been sealed")


func _log(msg: String) -> void:
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"
	var bar: VScrollBar = $VBoxContainer/TextEdit.get_v_scroll_bar()
	bar.value = bar.max_value


func _on_peers_pressed() -> void:
	_log(str(get_tree().get_multiplayer().get_peers()))

func _on_seal_pressed() -> void:
	client.seal_lobby()

func _on_start_pressed(single_player: bool = false) -> void:
	if not multiprocess.is_multiprocess_instance() and multiprocess_checkbox.button_pressed:
		_log("Starting multiplayer multiprocess instance")
		multiprocess.start_headless_process(false)
	else:
		var client_to_use: WebsocketSignalingClient
		if single_player:
			client_to_use = _create_singleplayer_client()
		else:
			client_to_use = client
		client_to_use.start(_get_url(single_player), "", mesh.button_pressed)

func _get_url(single_player: bool) -> String:
	var url: String
	if single_player:
		url = "ws://127.0.0.1:9080"
	else:
		url = host.text
	return url

func _on_join_pressed(single_player: bool = false) -> void:
	if room.text.is_empty():
		_log("Please enter room code")
		return

	var client_to_use: WebsocketSignalingClient
	if single_player:
		client_to_use = _create_singleplayer_client()
	else:
		client_to_use = client

	client_to_use.start(_get_url(single_player), room.text, mesh.button_pressed)

func _create_singleplayer_client() -> LocalhostSignalingClientWS:
	_log("Creating single player client")
	var client_to_use: LocalhostSignalingClientWS = LocalhostSignalingClientWS.new()
	add_child(client_to_use)
	_connect_signals(client_to_use)
	return client_to_use

func _on_refresh_pressed() -> void:
	client.start(host.text, "", mesh.button_pressed, false)

func _on_stop_pressed() -> void:
	print("Stop pressed")
	if multiprocess.is_multiprocess_instance_running():
		multiprocess.kill_headless_process()
	client.stop()

func _on_start_game_pressed():
	if multiprocess.is_multiprocess_instance_running():
		_on_start_game_pressed_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)
	elif not multiprocess.is_multiprocess_instance() and multiprocess_checkbox.button_pressed:
		_log("Starting single player multiprocess instance")
		multiprocess.start_headless_process(true)
	elif MultiplayerSceneSwitcher.switch_scenes(self, main.gameScene):
		client.seal_lobby()
		multiplayerUiRoot.visible = false
	else:
		_log("Cannot start game without authority")

@rpc("any_peer", "call_remote", "reliable")
func _on_start_game_pressed_rpc():
	if not multiprocess.is_rpc_safe(self):
		printerr("Invalid state")
		return
	
	_on_start_game_pressed()

func _on_room_list_activated(id: int) -> void:
	var current_state: WebSocketPeer.State = client.ws.get_ready_state()
	if current_state != WebSocketPeer.State.STATE_CLOSED:
		print("Client state %s is not closed" % current_state)
		return

	var room: String = room_list.get_item_metadata(id)
	client.start(host.text, room, mesh.button_pressed)

func _room_list_received(received_rooms: Dictionary) -> void:
	_log("Room list received: %s" % (JSON.stringify(received_rooms.keys()) if received_rooms else "[]"))
	room_list.clear()
	
	for room in received_rooms.keys():
		var id: int = room_list.add_item(room)
		room_list.set_item_metadata(id, room)
