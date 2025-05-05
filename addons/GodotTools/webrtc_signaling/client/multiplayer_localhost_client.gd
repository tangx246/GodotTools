class_name LocalhostSignalingClient
extends WebsocketSignalingClient

var rtc_mp := ENetMultiplayerPeer.new()
var sealed := false

const port: int = 25743

func _init() -> void:
	connected.connect(_connected)
	disconnected.connect(_disconnected)

	offer_received.connect(_offer_received)
	answer_received.connect(_answer_received)
	candidate_received.connect(_candidate_received)

	lobby_joined.connect(_lobby_joined)
	lobby_sealed.connect(_lobby_sealed)
	peer_connected.connect(_peer_connected)
	peer_disconnected.connect(_peer_disconnected)


func start(url: String, _lobby: String = "", _mesh: bool = true, _autojoin: bool = true) -> void:
	stop()
	sealed = false
	mesh = _mesh
	lobby = _lobby
	autojoin = _autojoin
	connect_to_url(url)

func _exit_tree() -> void:
	stop()

func stop() -> void:
	var default_peer: MultiplayerPeer = MultiplayerAPI.create_default_interface().multiplayer_peer
	get_tree().get_multiplayer().multiplayer_peer = default_peer
	rtc_mp.close()
	close()


func _new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type: String, data: String, id: int) -> void:
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func _connected(id: int, use_mesh: bool) -> void:
	print("Connected %d, mesh: %s" % [id, use_mesh])
	var error: Error
	#if use_mesh:
	#	printerr("Mesh currently unsupported")
	if id == 1:
		error = rtc_mp.create_server(port)
	else:
		error = rtc_mp.create_client("127.0.0.1", port)
	if error != Error.OK:
		printerr("Error creating peer: %s" % error)
	get_tree().get_multiplayer().multiplayer_peer = rtc_mp


func _lobby_joined(_lobby: String) -> void:
	lobby = _lobby


func _lobby_sealed() -> void:
	sealed = true


func _disconnected() -> void:
	print("Disconnected: %d: %s" % [code, reason])
	stop() # Unexpected disconnect


func _peer_connected(id: int) -> void:
	print("Peer connected: %d" % id)


func _peer_disconnected(id: int) -> void:
	if rtc_mp.has_peer(id):
		rtc_mp.remove_peer(id)

func _offer_received(id: int, offer: String) -> void:
	print("Got offer: %d, %s" % [id, offer])


func _answer_received(id: int, answer: String) -> void:
	print("Got answer: %d, %s" % [id, answer])


func _candidate_received(id: int, mid: String, index: int, sdp: String) -> void:
	pass
