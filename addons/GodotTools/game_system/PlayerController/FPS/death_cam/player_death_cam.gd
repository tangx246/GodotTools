extends Node3D

@onready var cam: Camera3D = %Camera3D

var players: Array[Node3D]
var current_player_idx: int = 0

func _ready() -> void:
	players.assign(get_tree().get_nodes_in_group("player"))
	cam.make_current()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and\
		event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_player_idx  = (current_player_idx + 1) % players.size()
		else:
			current_player_idx  = (current_player_idx - 1) % players.size()
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .002 * PlayerPrefs.get_value(MouseLookSensitivity.MOUSE_LOOK_KEY, 1.0))

func _process(_delta: float) -> void:
	var current_player: Node3D = players[current_player_idx] if current_player_idx < players.size() else null
	if not current_player:
		return

	global_position = current_player.global_position
