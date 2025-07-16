extends TabContainer

@onready var client: SignalingClient = %Client

func _on_node_added(node: Node) -> void:
	if node is SignalingClient:
		node.connected.connect(_on_connected)
		node.disconnected.connect(_on_disconnected)

func _ready() -> void:
	current_tab = 0
	get_tree().get_multiplayer().connected_to_server.connect(_on_lobby_joined)
	client.connected.connect(_on_connected)
	client.disconnected.connect(_on_disconnected)

	Signals.safe_connect(self, get_tree().node_added, _on_node_added)

func _on_connected(id: int, mesh: bool) -> void:
	if id == 1: 
		_on_lobby_joined()

func _on_lobby_joined() -> void:
	current_tab = 1
	
func _on_disconnected() -> void:
	current_tab = 0
