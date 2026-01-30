class_name WebsocketSignalingClient
extends SignalingClient

enum Message {
	JOIN,
	ID,
	PEER_CONNECT,
	PEER_DISCONNECT,
	OFFER,
	ANSWER,
	CANDIDATE,
	SEAL,
	REFRESH_ROOM_LIST
}

@export var autojoin := true
@export var lobby := ""  # Will create a new lobby if empty.
@export var mesh := true  # Will use the lobby host as relay otherwise.

var ws := WebSocketPeer.new()
var old_state := WebSocketPeer.STATE_CLOSED

signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal offer_received(id: int, offer: String)
signal answer_received(id: int, answer: String)
signal candidate_received(id: int, mid: String, index: int, sdp: String)

func connect_to_url(url: String) -> void:
	close()
	code = 1000
	reason = "Unknown"
	var err: Error = ws.connect_to_url(url)
	if err != Error.OK:
		push_error("Unable to connect to %s. Code: %s" % [url, err])

func close() -> void:
	ws.close()

func _room_list_callback(_ignore: Dictionary):
	close()
	if room_list_received.is_connected(_room_list_callback):
		room_list_received.disconnect(_room_list_callback)

func _process(_delta: float) -> void:
	ws.poll()
	var state := ws.get_ready_state()
	if state != old_state and state == WebSocketPeer.STATE_OPEN:
		if autojoin:
			join_lobby(lobby)
		else:
			refresh_room_list()
			if not room_list_received.is_connected(_room_list_callback):
				room_list_received.connect(_room_list_callback)
	while state == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count():
		if not _parse_msg():
			print("Error parsing message from server.")
	if state != old_state and state == WebSocketPeer.STATE_CLOSED:
		code = ws.get_close_code()
		reason = ws.get_close_reason()

		# If the underlying WebSocket signaling server has disconnected (e.g. due to lobby sealing), but we are still connected, stay in game
		var conn_status = get_tree().get_multiplayer().multiplayer_peer.get_connection_status()
		print("Current rtc_mp connection status: %s" % conn_status)
		if conn_status != MultiplayerPeer.CONNECTION_CONNECTED:
			disconnected.emit()
	old_state = state


func _parse_msg() -> bool:
	var parsed: Dictionary = JSON.parse_string(ws.get_packet().get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("type") or not parsed.has("id") or \
		typeof(parsed.get("data")) != TYPE_STRING:
		return false

	var msg := parsed as Dictionary
	# Godot 4.4 changed is_valid_int() behavior
	#if not str(msg.type).is_valid_int() or not str(msg.id).is_valid_int():
		#return false

	var type := str(msg.type).to_int()
	var src_id := str(msg.id).to_int()

	if type == Message.ID:
		connected.emit(src_id, msg.data == "true")
	elif type == Message.JOIN:
		lobby_joined.emit(msg.data)
	elif type == Message.SEAL:
		lobby_sealed.emit()
	elif type == Message.PEER_CONNECT:
		# Client connected.
		peer_connected.emit(src_id)
	elif type == Message.PEER_DISCONNECT:
		# Client connected.
		peer_disconnected.emit(src_id)
	elif type == Message.OFFER:
		# Offer received.
		offer_received.emit(src_id, msg.data)
	elif type == Message.ANSWER:
		# Answer received.
		answer_received.emit(src_id, msg.data)
	elif type == Message.CANDIDATE:
		# Candidate received.
		var candidate: PackedStringArray = msg.data.split("\n", false)
		if candidate.size() != 3:
			return false
		# Godot 4.4 changed is_valid_int behavior
		#if not candidate[1].is_valid_int():
			#return false
		candidate_received.emit(src_id, candidate[0], candidate[1].to_int(), candidate[2])
	elif type == Message.REFRESH_ROOM_LIST:
		room_list_received.emit(JSON.parse_string(msg.data))
	else:
		return false

	return true  # Parsed.


func join_lobby(lobby: String) -> Error:
	var player_name: String = get_tree().get_first_node_in_group(PlayerInfo.GROUP).get_player_name(false)
	var packet := JoinPacket.new()
	packet.lobby = lobby
	packet.host_name = player_name
	return _send_msg(Message.JOIN, 0 if mesh else 1, packet.to_string())

func seal_lobby() -> Error:
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return Error.ERR_CONNECTION_ERROR
	
	return _send_msg(Message.SEAL, 0)

func refresh_room_list() -> Error:
	return _send_msg(Message.REFRESH_ROOM_LIST, 0)

func send_candidate(id: int, mid: String, index: int, sdp: String) -> Error:
	print("Sending new candidate: %s" % id)
	return _send_msg(Message.CANDIDATE, id, "\n%s\n%d\n%s" % [mid, index, sdp])


func send_offer(id: int, offer: String) -> Error:
	return _send_msg(Message.OFFER, id, offer)


func send_answer(id: int, answer: String) -> Error:
	return _send_msg(Message.ANSWER, id, answer)


func _send_msg(type: int, id: int, data: String = "") -> Error:
	return ws.send_text(JSON.stringify({
		"type": type,
		"id": id,
		"data": data,
	}))
