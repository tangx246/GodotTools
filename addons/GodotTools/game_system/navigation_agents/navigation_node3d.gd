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

func _ready() -> void:
	ticks = randi() % tick_rate

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
		new_velocity = global_position.direction_to(next_path_position) * speed * tick_rate
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	_stick_to_floor()

func _stick_to_floor() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position - Vector3(0, 0.05, 0), global_position - Vector3(0, 1, 0), floor_mask, [self])
	var result = space_state.intersect_ray(query)

	if result:
		navigation_agent.path_height_offset = (global_position - result.position).length()

func _on_velocity_computed(safe_velocity: Vector3):	
	velocity = safe_velocity
	var new_pos: Vector3 = global_position.move_toward(global_position + safe_velocity, speed * get_physics_process_delta_time())
	if safe_velocity.length_squared() > 0.01:
		look_at(new_pos)
	global_position = new_pos

func is_on_floor():
	return true
