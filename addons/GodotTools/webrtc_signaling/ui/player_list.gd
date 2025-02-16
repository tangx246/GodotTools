extends ItemList

@onready var client: WSWebRTCSignalingClient = %Client

func _ready() -> void:
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_changed.unbind(1))
	client.connected.connect(_on_peer_changed.unbind(2))
	client.peer_disconnected.connect(_on_peer_changed.unbind(1))
	
func _on_peer_changed() -> void:
	clear()
	add_item("%s (Me)" % client.rtc_mp.get_unique_id())
	for peer: int in client.rtc_mp.get_peers():
		add_item(str(peer))
