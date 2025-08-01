class_name WSWebRTCSignalingClient
extends WebsocketSignalingClient

var rtc_mp := WebRTCMultiplayerPeer.new()
var sealed := false

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


func _create_peer(id: int) -> WebRTCPeerConnection:
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	# Use a public STUN server for moderate NAT traversal.
	# Note that STUN cannot punch through strict NATs (such as most mobile connections),
	# in which case TURN is required. TURN generally does not have public servers available,
	# as it requires much greater resources to host (all traffic goes through
	# the TURN server, instead of only performing the initial connection).
	var error: Error = peer.initialize({
		"iceServers": [ { "urls": [
			"stun:stun.l.google.com:19302",
			"stun:stun1.l.google.com:19302",
			"stun:stun2.l.google.com:19302",
			"stun:stun3.l.google.com:19302",
			"stun:stun4.l.google.com:19302",
		] } ]
	})
	if error != Error.OK:
		push_error("WebRTCPeer initialization failed: %s" % error)
	peer.session_description_created.connect(_offer_created.bind(id))
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(id))
	error = rtc_mp.add_peer(peer, id)
	if error != Error.OK:
		push_error("Adding peer failed %s" % error)
	if id < rtc_mp.get_unique_id():  # So lobby creator never creates offers.
		error = peer.create_offer()
		if error != Error.OK:
			push_error("Creating offer failed: %s" % error)
	return peer


func _new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type: String, data: String, id: int) -> void:
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	var err: Error = rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if err != Error.OK:
		push_error("Error creating local description. Code: %s. %s, %s" % [err, type, data])
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)


func _connected(id: int, use_mesh: bool) -> void:
	print("Connected %d, mesh: %s" % [id, use_mesh])
	var error: Error
	if use_mesh:
		error = rtc_mp.create_mesh(id)
	elif id == 1:
		error = rtc_mp.create_server()
	else:
		error = rtc_mp.create_client(id)
	if error != Error.OK:
		push_error("Error creating peer: %s" % error)
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
	_create_peer(id)


func _peer_disconnected(id: int) -> void:
	if rtc_mp.has_peer(id):
		rtc_mp.remove_peer(id)

func _offer_received(id: int, offer: String) -> void:
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		var error: Error = rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)
		if error != Error.OK:
			push_error("Unable to set remote description %s, %s" % [error, offer])


func _answer_received(id: int, answer: String) -> void:
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		var error: Error = rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)
		if error != Error.OK:
			push_error("Unable to set remote description: %s, %s" % [error, answer])


func _candidate_received(id: int, mid: String, index: int, sdp: String) -> void:
	if rtc_mp.has_peer(id):
		var error: Error = rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
		if error != Error.OK:
			push_error("Unable to add ice candidate: %s, %s, %s" % [error, index, sdp])
