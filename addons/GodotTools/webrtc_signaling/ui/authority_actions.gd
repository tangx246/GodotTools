extends HBoxContainer

@onready var client: WSWebRTCSignalingClient = %Client
@onready var multiprocess: Multiprocess = %Multiprocess

func _ready() -> void:
	get_tree().get_multiplayer().connected_to_server.connect(_on_connected)
	get_tree().get_multiplayer().peer_connected.connect(_on_connected.unbind(1) )

func _on_connected() -> void:
	_set_children(get_tree().current_scene.is_multiplayer_authority() or multiprocess.is_multiprocess_instance_running())
		
func _set_children(enabled: bool):
	for child: Button in get_children():
		child.disabled = not enabled
