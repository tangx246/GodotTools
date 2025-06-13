class_name NavigationNode3D
extends Node3D

@export var speed: float = 4
@export var tick_rate: int = 1
@export_flags_3d_physics var floor_mask: int = 1 << 0
var navigation_agent: NavigationAgent3D
var velocity: Vector3

func _enter_tree() -> void:
	navigation_agent = get_node("NavigationAgent3D")
	navigation_agent.velocity_computed.connect(_on_velocity_computed)

func _exit_tree() -> void:
	navigation_agent.velocity_computed.disconnect(_on_velocity_computed)

var raycast: RayCast3D
func _ready() -> void:
	ticks = randi() % tick_rate
	
	raycast = RayCast3D.new()
	raycast.collision_mask = floor_mask
	raycast.position = raycast.position + Vector3(0, 0.5, 0)
	raycast.target_position = Vector3(0, -1.5, 0)
	add_child(raycast)

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
	
	_stick_to_floor()

func _stick_to_floor() -> void:
	if raycast.is_colliding():
		navigation_agent.path_height_offset = (global_position - raycast.get_collision_point()).length()

func _on_velocity_computed(safe_velocity: Vector3):	
	velocity = safe_velocity
	WorkerThreadPoolExtended.add_task(_calculate_new_pos_and_look.bind(global_position, safe_velocity, speed * get_physics_process_delta_time()))

func _calculate_new_pos_and_look(pos: Vector3, safe_velocity: Vector3, delta: float) -> void:
	if safe_velocity.length_squared() > 0.01:
		var horizontal: Vector3 = Plane.PLANE_XZ.project(safe_velocity)
		look_at.call_deferred(global_transform.translated(horizontal).origin)
		_move_to.call_deferred(pos.move_toward(pos + safe_velocity, delta))

func _move_to(target: Vector3):
	global_position = target

func is_on_floor() -> bool:
	return true
