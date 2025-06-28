extends Node3D

@onready var cam: Camera3D = %Camera3D
@onready var pitch: Node3D = %Pitch
@onready var spring_arm: SpringArm3D = %SpringArm3D
@export var cam_offset: Vector3 = Vector3.UP
@export var min_distance: float = 2
@export var max_distance: float = 5

var players: Array[Node3D]
var current_player_idx: int = 0

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	
	players.assign(get_tree().get_nodes_in_group("player"))
	cam.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and\
		event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_player_idx  = (current_player_idx + 1) % players.size()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			current_player_idx  = (current_player_idx - 1) % players.size()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(-.2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(.2)
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .002 * PlayerPrefs.get_value(MouseLookSensitivity.MOUSE_LOOK_KEY, 1.0))
		pitch.rotate_x(-event.relative.y * .002 * PlayerPrefs.get_value(MouseLookSensitivity.MOUSE_LOOK_KEY, 1.0))
		pitch.rotation.x = clampf(pitch.rotation.x, -PI/4, PI/4)

func _zoom(amount: float) -> void:
	spring_arm.spring_length = clampf(spring_arm.spring_length + amount, min_distance, max_distance)

func _process(_delta: float) -> void:
	var current_player: Node3D = players[current_player_idx] if current_player_idx < players.size() else null
	if not current_player:
		return

	global_position = current_player.global_position
	cam.look_at(position + cam_offset)
