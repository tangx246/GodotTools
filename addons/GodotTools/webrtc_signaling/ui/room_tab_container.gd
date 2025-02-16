extends TabContainer

@onready var client: WSWebRTCSignalingClient = %Client

func _ready() -> void:
	current_tab = 0
	get_tree().get_multiplayer().connected_to_server.connect(_on_lobby_joined)
	client.connected.connect(func(id: int, mesh: bool):
		if id == 1: 
			_on_lobby_joined())
	client.disconnected.connect(_on_disconnected)

func _on_lobby_joined() -> void:
	current_tab = 1
	
func _on_disconnected() -> void:
	current_tab = 0
