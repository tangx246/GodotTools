class_name NavigationCharBody3D
extends CharacterBody3D

@export var speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	var horizontal_velocity: Vector3 = Plane.PLANE_XZ.project(safe_velocity).normalized() * speed
	velocity = horizontal_velocity + calculate_gravity_velocity()
	move_and_slide()
	if horizontal_velocity.length() > 0.01:
		look_at(global_transform.translated(horizontal_velocity).origin)

var gravity_velocity: Vector3 = Vector3.ZERO
func calculate_gravity_velocity() -> Vector3:
	if is_on_floor():
		gravity_velocity = Vector3.ZERO
	else:
		gravity_velocity += get_gravity() * get_physics_process_delta_time()

	return gravity_velocity