extends CharacterBody3D

@export var speed : float = 10.0
@export var jump_height : float = 1
@export var acceleration : float = 100
@export var use_transform_basis : bool = false
#@export var angular_acceleration : float = 10
@export var jump_key : String = "ui_accept"
@export var camera_basis : Node3D = null
@export var additional_rotation : Vector3 = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += (gravity_direction * gravity) * delta

	# Handle Jump.
	if Input.is_action_just_pressed(jump_key) and is_on_floor():
		var jump_magnitude = sqrt(gravity * 2 * jump_height)
		velocity = gravity_direction * -jump_magnitude

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if use_transform_basis:
		direction = transform.basis * direction
		
	if camera_basis:
		var camera_relative_direction = camera_basis.quaternion * direction
		var camera_projection = Plane.PLANE_XZ.project(camera_relative_direction)
		direction = camera_projection.normalized()
	
	if additional_rotation != Vector3.ZERO:
		var quaternion = Quaternion.from_euler(additional_rotation)
		direction *= quaternion
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)

	move_and_slide()

	if direction != Vector3.ZERO:
		var tween = create_tween()
		tween.tween_property(self, "rotation", Vector3(rotation.x, atan2(direction.x, direction.z), rotation.z), 0.2)
		#rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), delta * angular_acceleration)
