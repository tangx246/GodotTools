extends TabContainer

@onready var client: WebsocketSignalingClient = %Client

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return

	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)

func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is WebsocketSignalingClient:
		node.connected.connect(_on_connected)
		node.disconnected.connect(_on_disconnected)

func _ready() -> void:
	current_tab = 0
	get_tree().get_multiplayer().connected_to_server.connect(_on_lobby_joined)
	client.connected.connect(_on_connected)
	client.disconnected.connect(_on_disconnected)

func _on_connected(id: int, mesh: bool) -> void:
	if id == 1: 
		_on_lobby_joined()

func _on_lobby_joined() -> void:
	current_tab = 1
	
func _on_disconnected() -> void:
	current_tab = 0
