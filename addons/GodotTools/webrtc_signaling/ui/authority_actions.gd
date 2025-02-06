extends HBoxContainer

@onready var client: WSWebRTCSignalingClient = %Client

func _ready() -> void:
	client.webrtc_connected.connect(_on_connected.unbind(2))

func _on_connected() -> void:
	_set_children(get_tree().current_scene.is_multiplayer_authority())
		
func _set_children(enabled: bool):
	for child: Button in get_children():
		child.disabled = not enabled
