extends ItemList

@onready var pinfo: PlayerInfo = get_tree().get_first_node_in_group(PlayerInfo.GROUP)

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	
	Signals.safe_connect(self, pinfo.player_info_updated, _refresh_names)
	_refresh_names()

func _refresh_names() -> void:
	clear()

	var players: Dictionary[int, PlayerInfo.Player] = pinfo.get_players()
	for key in players:
		var player: PlayerInfo.Player = players[key]
		var format_string: String
		if player.id == multiplayer.get_unique_id():
			format_string = "%s - %s (Me)"
		else:
			format_string = "%s - %s"

		add_item(format_string % [player.id, player.name], player.avatar)