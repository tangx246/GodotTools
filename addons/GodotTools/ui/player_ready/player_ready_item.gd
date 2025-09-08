class_name PlayerReadyItem
extends Control

@onready var pinfo: PlayerInfo = get_tree().get_first_node_in_group(PlayerInfo.GROUP)
@onready var ready_rect: TextureRect = %Ready
@onready var player_icon_rect: TextureRect = %PlayerIcon
@onready var label: Label = %Label
@onready var kick_button: Button = %KickButton

signal player_kicked(multiplayer_id: int)

@onready var player_ready: PlayerReady = get_tree().get_first_node_in_group(PlayerReady.GROUP)
var multiplayer_id: int = -1

func _ready() -> void:
	Signals.safe_connect(self, pinfo.player_info_updated, _refresh)
	Signals.safe_connect(self, player_ready.ready_changed, _refresh)

func setup(_multiplayer_id: int) -> void:
	multiplayer_id = _multiplayer_id
	_refresh()

func _refresh() -> void:
	if multiplayer_id <= -1:
		return

	var players := pinfo.get_players()
	if not players.has(multiplayer_id):
		return

	label.text = "{id}: {name}{me_suffix}".format({
		"id": str(multiplayer_id),
		"name": players[multiplayer_id].name,
		"me_suffix": " (Me)" if multiplayer_id == multiplayer.get_unique_id() else ""
	})

	ready_rect.texture = player_ready.ready_icon if player_ready.is_ready(multiplayer_id) else player_ready.not_ready_icon
	player_icon_rect.texture = players[multiplayer_id].avatar

	if (is_multiplayer_authority() or Multiprocess.get_first_instance(self).is_multiprocess_instance_running()) and multiplayer_id != MultiplayerPeer.TARGET_PEER_SERVER and multiplayer_id != multiplayer.get_unique_id():
		kick_button.visible = true
		Signals.safe_connect(self, kick_button.pressed, player_kicked.emit.bind(multiplayer_id))
	else:
		kick_button.visible = false
