extends CharacterBody3D


@export var speed : float = 10.0
@export var jump_height : float = 1
@export var acceleration : float = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_direction = ProjectSettings.get_setting("physics/3d/default_gravity_vector")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += (gravity_direction * gravity) * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		var jump_magnitude = sqrt(gravity * 2 * jump_height)
		velocity = gravity_direction * -jump_magnitude

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)

	move_and_slide()
