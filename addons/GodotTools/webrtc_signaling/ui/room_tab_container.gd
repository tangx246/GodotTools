extends TabContainer

@onready var client: WebsocketSignalingClient = %Client

func _ready() -> void:
	current_tab = 0
	client.lobby_joined.connect(_on_lobby_joined.unbind(1))
	client.disconnected.connect(_on_disconnected)

func _on_lobby_joined() -> void:
	current_tab = 1
	
func _on_disconnected() -> void:
	current_tab = 0
