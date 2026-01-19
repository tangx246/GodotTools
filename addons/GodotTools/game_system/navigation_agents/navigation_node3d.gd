class_name NavigationNode3D
extends Node3D

@export var speed: float = 4
@export var tick_rate: int = 1
@export var long_distance_debounce_rate: int = 100
@export var long_distance: float = 30
@export var player_group: StringName = "player"
@onready var model: Node3D = %Model
var navigation_agent: NavigationAgent3D
var velocity: Vector3

const CUSTOM_MONITOR: StringName = "game/navigation_nodes"
static var nodes: int = 0
func _enter_tree() -> void:
	nodes += 1
	if not Performance.has_custom_monitor(CUSTOM_MONITOR):
		Performance.add_custom_monitor(CUSTOM_MONITOR, func(): return nodes)

func _exit_tree() -> void:
	nodes -= 1

var tick_variance: int
func _ready() -> void:
	navigation_agent = get_node("NavigationAgent3D")
	
	tick_variance = randi() % 10000
	
	Signals.safe_connect(self, navigation_agent.velocity_computed, _on_velocity_computed)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta: float) -> void:
	if (Engine.get_physics_frames() + tick_variance) % tick_rate != 0:
		return
		
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3
	if next_path_position.is_equal_approx(position):
		new_velocity = Vector3.ZERO
	else:
		new_velocity = global_position.direction_to(next_path_position) * speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

var queued: bool = false
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity

	if queued:
		return

	queued = true

	var debounce_rate: int = long_distance_debounce_rate
	for player: Node3D in get_tree().get_nodes_in_group(player_group):
		if player.global_position.distance_to(global_position) < long_distance:
			debounce_rate = 0
			break

	var loops: int = randi_range(0, debounce_rate)
	for i in range(loops):
		await Engine.get_main_loop().physics_frame

	_calculate_new_pos_and_look(global_position, safe_velocity, speed * get_physics_process_delta_time() * (loops + 1))
	queued = false

func _calculate_new_pos_and_look(pos: Vector3, safe_velocity: Vector3, delta: float) -> void:
	var horizontal: Vector3 = Plane.PLANE_XZ.project(safe_velocity)
	var look_position: Vector3 = global_transform.translated(horizontal).origin
	if (look_position - global_position).length_squared() > 0.01:
		look_at(look_position)
	_move_to(pos.move_toward(pos + safe_velocity, delta))

func _move_to(target: Vector3):
	global_position = target

func is_on_floor() -> bool:
	return true
