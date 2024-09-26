extends Control

@onready var client: Node = $Client
@onready var host: LineEdit = $VBoxContainer/Connect/Host
@onready var room: LineEdit = $VBoxContainer/Join/RoomSecret
@onready var mesh: CheckBox = $VBoxContainer/Connect/Mesh
@onready var multiplayerUi: Control = %VBoxContainer
@onready var multiplayerUiRoot: Control = $"%VBoxContainer/.."
@onready var gameRoot: Node

func _ready() -> void:
	gameRoot = get_tree().get_first_node_in_group("GameRoot")
	
	client.lobby_joined.connect(_lobby_joined)
	client.lobby_sealed.connect(_lobby_sealed)
	client.connected.connect(_connected)
	client.disconnected.connect(_disconnected)

	multiplayer.connected_to_server.connect(_mp_server_connected)
	multiplayer.connection_failed.connect(_mp_server_disconnect)
	multiplayer.server_disconnected.connect(_mp_server_disconnect)
	multiplayer.peer_connected.connect(_mp_peer_connected)
	multiplayer.peer_disconnected.connect(_mp_peer_disconnected)
	
	get_tree().get_multiplayer().connected_to_server.connect(_mp_server_connected)
	get_tree().get_multiplayer().connection_failed.connect(_mp_server_disconnect)
	get_tree().get_multiplayer().server_disconnected.connect(_mp_server_disconnect)
	get_tree().get_multiplayer().peer_connected.connect(_mp_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_mp_peer_disconnected)

func _mp_server_connected() -> void:
	_log("[Multiplayer] Server connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect() -> void:
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int) -> void:
	_log("[Multiplayer] Peer %d connected" % id)


func _mp_peer_disconnected(id: int) -> void:
	_log("[Multiplayer] Peer %d disconnected" % id)


func _connected(id: int, use_mesh: bool) -> void:
	_log("[Signaling] Server connected with ID: %d. Mesh: %s" % [id, use_mesh])


func _disconnected() -> void:
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])


func _lobby_joined(lobby: String) -> void:
	_log("[Signaling] Joined lobby %s" % lobby)


func _lobby_sealed() -> void:
	_log("[Signaling] Lobby has been sealed")


func _log(msg: String) -> void:
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"
	var bar : VScrollBar = $VBoxContainer/TextEdit.get_v_scroll_bar()
	bar.value = bar.max_value


func _on_peers_pressed() -> void:
	_log(str(get_tree().get_multiplayer().get_peers()))

func _on_seal_pressed() -> void:
	client.seal_lobby()


func _on_start_pressed() -> void:
	client.start(host.text, "", mesh.button_pressed)
	
func _on_join_pressed() -> void:
	if room.text.is_empty():
		_log("Please enter room code")
		return

	client.start(host.text, room.text, mesh.button_pressed)

func _on_stop_pressed() -> void:
	client.stop()

func _on_start_game_pressed():
	if get_tree().get_multiplayer().get_unique_id() == get_multiplayer_authority():
		multiplayerUiRoot.visible = false
		for child in gameRoot.get_children():
			gameRoot.remove_child(child)
			child.queue_free()
		var new_scene = gameRoot.get_parent().gameScene.instantiate()
		gameRoot.add_child(new_scene, true)
	else:
		_log("Cannot start game without authority")
