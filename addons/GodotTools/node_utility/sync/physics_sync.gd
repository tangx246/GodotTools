class_name PhysicsSync

## Waits for physics frame if not currently in a physics frame
static func wait_for_physics_frame() -> void:
	if not Engine.is_in_physics_frame():
		await Engine.get_main_loop().physics_frame
