class_name PlayerReady
extends Control

@export var ready_icon: Texture2D
@export var not_ready_icon: Texture2D
@export var player_ready_item: PackedScene
@onready var list: Control = %List
@onready var pinfo: PlayerInfo = get_tree().get_first_node_in_group(PlayerInfo.GROUP)
@onready var toggle_ready_button: Button = %Button
@onready var synchronizer: MultiplayerSynchronizer = %MultiplayerSynchronizerWorkaround

# Maps player ID to ready state
@export var ready_state: Dictionary[int, bool] = {}
signal ready_changed

const GROUP: StringName = "PlayerReady"

func _init() -> void:
	add_to_group(GROUP)

func _ready() -> void:
	if is_multiplayer_authority() or Multiprocess.get_first_instance(self).is_multiprocess_instance_running():
		toggle_ready()
		toggle_ready_button.visible = false

	Signals.safe_connect(self, toggle_ready_button.pressed, toggle_ready)
	Signals.safe_connect(self, multiplayer.peer_connected, _on_ready_changed.unbind(1))
	Signals.safe_connect(self, multiplayer.peer_disconnected, _on_ready_changed.unbind(1))
	Signals.safe_connect(self, synchronizer.delta_synchronized, ready_changed.emit)
	Signals.safe_connect(self, ready_changed, _on_ready_changed)
	Signals.safe_connect(self, pinfo.player_info_updated, _on_ready_changed)
	_on_ready_changed()

func _on_ready_changed() -> void:
	var players := pinfo.get_players()
	_clear()
	var self_id: int = multiplayer.get_unique_id()
	_add_item("{id}: {name} (Me)".format({
		"id": str(self_id),
		"name": players[self_id].name
	}), ready_icon if _is_ready(self_id) else not_ready_icon,
	players[self_id].avatar)

	for id in multiplayer.get_peers():
		_add_item("{id}: {name}".format({
			"id": str(id),
			"name": players[id].name
		}), ready_icon if _is_ready(id) else not_ready_icon,
		players[id].avatar)

	toggle_ready_button.text = "Ready" if not _is_ready(self_id) else "Unready"

func toggle_ready() -> void:
	_toggle_ready_rpc.rpc_id(get_multiplayer_authority())

@rpc("any_peer", "call_local", "reliable")
func _toggle_ready_rpc() -> void:
	var id: int = multiplayer.get_remote_sender_id()
	ready_state[id] = not _is_ready(id)
	ready_changed.emit()

func _is_ready(id: int) -> bool:
	if ready_state.has(id):
		return ready_state[id]
	return false

func all_ready() -> bool:
	var ids: Array[int] = [multiplayer.get_unique_id()]
	ids.append_array(multiplayer.get_peers())

	for id in ids:
		if not _is_ready(id):
			return false
	return true

func _clear() -> void:
	for child in list.get_children():
		child.queue_free()

func _add_item(text: String, icon: Texture2D, player_icon: Texture2D) -> void:
	var instantiated: Control = player_ready_item.instantiate()
	
	var ready_rect: TextureRect = instantiated.get_node(^"%Ready")
	ready_rect.texture = icon

	var player_icon_rect: TextureRect = instantiated.get_node(^"%PlayerIcon")
	player_icon_rect.texture = player_icon
	
	var label: Label = instantiated.get_node(^"%Label")
	label.text = text

	list.add_child(instantiated)
