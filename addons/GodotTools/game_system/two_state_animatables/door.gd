class_name Door
extends TwoStateAnimatable

@export var doorway_collision_shape : CollisionShape3D

func is_open() -> bool:
	return doorway_collision_shape.disabled

## Called by Animator
func opened():
	doorway_collision_shape.disabled = true
	
## Called by Animator
func closed():
	doorway_collision_shape.disabled = false
