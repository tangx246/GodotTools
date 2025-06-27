extends Button

@onready var new_save_name: LineEdit = %NewSaveName

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	_save_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, new_save_name.text)
	get_window().hide()

@rpc("any_peer", "call_local", "reliable")
func _save_rpc(save_name: String) -> void:
	GameState.save_game(1000000, save_name) # Just make up a large number
