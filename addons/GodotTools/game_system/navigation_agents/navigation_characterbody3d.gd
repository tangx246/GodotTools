class_name NavigationCharBody3D
extends CharacterBody3D

@export var speed: float = 4
@export var tick_rate: int = 1
var navigation_agent: NavigationAgent3D

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

func _on_velocity_computed(safe_velocity: Vector3):	
	var horizontal_velocity: Vector3 = Plane.PLANE_XZ.project(safe_velocity)
	velocity = horizontal_velocity + calculate_gravity_velocity()
	move_and_slide()
	if horizontal_velocity.length_squared() > 0.01:
		look_at(global_transform.translated(horizontal_velocity).origin)

var gravity_velocity: Vector3 = Vector3.ZERO
func calculate_gravity_velocity() -> Vector3:
	var gravity_multiplier: int
	if navigation_agent.avoidance_enabled:
		gravity_multiplier = 1
	else:
		gravity_multiplier = tick_rate
	
	if is_on_floor():
		gravity_velocity = Vector3.ZERO
	else:
		gravity_velocity += get_gravity() * get_physics_process_delta_time() * gravity_multiplier

	return gravity_velocity
