class_name NavigationNode3D
extends Node3D

@export var speed: float = 4
@export var tick_rate: int = 1
@export_flags_3d_physics var floor_mask: int = 1 << 0
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

var raycast: RayCast3D
func _ready() -> void:
	navigation_agent = get_node("NavigationAgent3D")
	
	ticks = randi() % tick_rate
	
	raycast = RayCast3D.new()
	raycast.collision_mask = floor_mask
	raycast.position = raycast.position + Vector3(0, 1, 0)
	raycast.target_position = Vector3(0, -3, 0)
	raycast.enabled = false
	add_child(raycast)

	Signals.safe_connect(self, navigation_agent.velocity_computed, _on_velocity_computed)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

var ticks: int = 0
func _physics_process(_delta: float) -> void:
	ticks = (ticks + 1) % tick_rate
	
	if ticks != 0:
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

func _stick_to_floor() -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		navigation_agent.path_height_offset = clampf(navigation_agent.path_height_offset + global_position.y - raycast.get_collision_point().y, 0, 0.5)

func _on_velocity_computed(safe_velocity: Vector3):	
	velocity = safe_velocity
	_calculate_new_pos_and_look(global_position, safe_velocity, speed * get_physics_process_delta_time())

func _calculate_new_pos_and_look(pos: Vector3, safe_velocity: Vector3, delta: float) -> void:
	var horizontal: Vector3 = Plane.PLANE_XZ.project(safe_velocity)
	var look_position: Vector3 = global_transform.translated(horizontal).origin
	if (look_position - global_position).length_squared() > 0.01:
		look_at(look_position)
	_move_to(pos.move_toward(pos + safe_velocity, delta))
	
	_stick_to_floor()

func _move_to(target: Vector3):
	global_position = target

func is_on_floor() -> bool:
	return true
