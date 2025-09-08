class_name PlayerReady
extends Control

@export var ready_icon: Texture2D
@export var not_ready_icon: Texture2D
@export var player_ready_item: PackedScene
@onready var list: Control = %List
@onready var pinfo: PlayerInfo = get_tree().get_first_node_in_group(PlayerInfo.GROUP)
@onready var toggle_ready_button: Button = %ToggleReadyButton
@onready var ping_players_button: Button = %PingPlayersButton
@onready var asp: AudioStreamPlayer = %AudioStreamPlayer
@onready var synchronizer: MultiplayerSynchronizer = %MultiplayerSynchronizerWorkaround

# Maps player ID to ready state
@export var ready_state: Dictionary[int, bool] = {}
signal ready_changed

const GROUP: StringName = "PlayerReady"

func _init() -> void:
	add_to_group(GROUP)

func _ready() -> void:
	if is_host():
		toggle_ready()
		toggle_ready_button.visible = false
		ping_players_button.visible = true
	else:
		toggle_ready_button.visible = true
		ping_players_button.visible = false

	Signals.safe_connect(self, ping_players_button.pressed, _ping_players.rpc)
	Signals.safe_connect(self, toggle_ready_button.pressed, toggle_ready)
	Signals.safe_connect(self, multiplayer.peer_connected, _on_ready_changed.unbind(1))
	Signals.safe_connect(self, multiplayer.peer_disconnected, _on_ready_changed.unbind(1))
	Signals.safe_connect(self, synchronizer.delta_synchronized, ready_changed.emit)
	Signals.safe_connect(self, ready_changed, _on_ready_changed)
	Signals.safe_connect(self, pinfo.player_info_updated, _on_ready_changed)
	_on_ready_changed()

func is_host() -> bool:
	return is_multiplayer_authority() or Multiprocess.get_first_instance(self).is_multiprocess_instance_running()

func _on_ready_changed() -> void:
	var players := pinfo.get_players()
	_clear()
	var self_id: int = multiplayer.get_unique_id()
	_add_item(self_id)

	for id in multiplayer.get_peers():
		_add_item(id)

	toggle_ready_button.text = "Ready" if not is_ready(self_id) else "Unready"

func toggle_ready() -> void:
	_toggle_ready_rpc.rpc_id(get_multiplayer_authority())

@rpc("any_peer", "call_local", "reliable")
func _toggle_ready_rpc() -> void:
	var id: int = multiplayer.get_remote_sender_id()
	ready_state[id] = not is_ready(id)
	ready_changed.emit()

func is_ready(id: int) -> bool:
	if ready_state.has(id):
		return ready_state[id]
	return false

func all_ready() -> bool:
	var ids: Array[int] = [multiplayer.get_unique_id()]
	ids.append_array(multiplayer.get_peers())

	for id in ids:
		if not is_ready(id):
			return false
	return true

func _clear() -> void:
	for child in list.get_children():
		child.queue_free()

func _add_item(multiplayer_id: int) -> void:
	var instantiated: PlayerReadyItem = player_ready_item.instantiate()
	list.add_child(instantiated)
	
	instantiated.setup(multiplayer_id)
	Signals.safe_connect(self, instantiated.player_kicked, _on_kick_pressed)

func _on_kick_pressed(id: int) -> void:
	_kick_rpc.rpc_id(get_multiplayer_authority(), id)

@rpc("any_peer", "call_local", "reliable")
func _kick_rpc(id: int) -> void:
	# Check permissions
	var remote_sender_id: int = multiplayer.get_remote_sender_id()
	if remote_sender_id != Multiprocess.get_first_instance(self).get_host() and remote_sender_id != MultiplayerPeer.TARGET_PEER_SERVER:
		push_error("Invalid permissions to kick player by %s" % remote_sender_id)
		return

	multiplayer.multiplayer_peer.disconnect_peer(id)

@rpc("any_peer", "call_local", "reliable")
func _ping_players() -> void:
	asp.play()
