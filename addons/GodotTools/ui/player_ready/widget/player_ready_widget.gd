extends HBoxContainer

@onready var player_ready: PlayerReady = get_tree().get_first_node_in_group(PlayerReady.GROUP)
@onready var player_ready_item: PlayerReadyItem = %PlayerReadyItem
@onready var ready_button: Button = %ReadyButton

func _ready() -> void:
	player_ready_item.setup(multiplayer.get_unique_id())
	Signals.safe_connect(self, ready_button.pressed, _toggle_ready)
	Signals.safe_connect(self, player_ready.ready_changed, _refresh)

	if player_ready.is_host():
		ready_button.visible = false
	else:
		ready_button.visible = true

func _toggle_ready() -> void:
	player_ready.toggle_ready()

func _refresh() -> void:
	if player_ready.is_ready(multiplayer.get_unique_id()):
		ready_button.text = "Unready"
	else:
		ready_button.text = "Ready"
