class_name TPSController
extends ShooterController

@export var body_rotation_speed: float = 10.0
@export var camera_pivot : Node3D

@onready var spring_arm : SpringArm3D = find_child("SpringArm3D")

func _ready() -> void:
	super()
	camera_pivot.top_level = true

func _process(delta: float) -> void:
	# Keep camera pivot following the player position (top_level detaches it from parent transforms)
	camera_pivot.global_position = stand_state_controller.global_position

	_accumulate_joy_look(delta)

	# Rotate camera pivot horizontally (yaw)
	camera_pivot.rotate_y(mouse_movement.x)

	# Rotate spring arm vertically (pitch) with clamping
	var prev_rotation_x: float = spring_arm.rotation.x
	spring_arm.rotate_x(mouse_movement.y)
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, deg_to_rad(-70), deg_to_rad(80))

	mouse_looked.emit(mouse_movement.x, spring_arm.rotation.x - prev_rotation_x)
	_reset_mouse_movement()

func _physics_process(delta):
	# Get camera-relative movement direction
	var input_dir = Input.get_vector("Strafe Left", "Strafe Right", "Move Forward", "Move Backward")
	input_direction = input_dir

	var cam_basis = camera_pivot.global_transform.basis
	var cam_forward = -cam_basis.z
	var cam_right = cam_basis.x
	# Flatten to horizontal plane
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
	cam_right.y = 0
	cam_right = cam_right.normalized()

	var move_direction = (cam_right * input_dir.x + cam_forward * -input_dir.y)

	velocity = Vector3(move_direction.x * speed, velocity.y, move_direction.z * speed)
	var gravity_direction = _apply_gravity_and_jump(delta)

	# Rotate body to face movement direction
	if move_direction.length() > 0.1:
		var target_angle = atan2(move_direction.x, move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, body_rotation_speed * delta)

	_move_and_detect_landing(gravity_direction)
