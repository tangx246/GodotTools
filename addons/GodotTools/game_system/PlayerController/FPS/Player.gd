class_name FPSController
extends ShooterController

func _process(delta: float) -> void:
	_accumulate_joy_look(delta)

	rotate_y(mouse_movement.x)
	var prev_rotation_x: float = camera.rotation.x
	camera.rotate_x(mouse_movement.y)
	camera.rotation.x = clampf(camera.rotation.x, -PI/2, PI/2)

	mouse_looked.emit(mouse_movement.x, camera.rotation.x - prev_rotation_x)
	_reset_mouse_movement()

func _physics_process(delta):
	velocity = get_input()
	var gravity_direction = _apply_gravity_and_jump(delta)
	velocity = global_transform.basis * velocity
	_move_and_detect_landing(gravity_direction)
