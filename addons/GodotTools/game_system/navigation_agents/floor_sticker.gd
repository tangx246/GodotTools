## Navigation meshes don't necessarily align with the floor.
## Shift the model of an entity onto the floor
class_name FloorSticker
extends Node3D

@export var root: Node3D
## If none given, will use %Model
@export var model: Node3D
@export var print_warning_if_model_not_found: bool = true
@export_flags_3d_physics var floor_mask: int = 1 << 0

var raycast: RayCast3D
func _ready() -> void:
	if not model:
		model = root.get_node_or_null(^"%Model")

		# We give up here
		if not model:
			if print_warning_if_model_not_found:
				push_warning("Unable to find model for %s" % get_path())
			set_physics_process(false)
			return

	if not is_multiplayer_authority():
		set_physics_process(false)
		return

	raycast = RayCast3D.new()
	raycast.collision_mask = floor_mask
	raycast.position = raycast.position + Vector3(0, 1, 0)
	raycast.target_position = Vector3(0, -100, 0)
	raycast.enabled = false
	add_child(raycast)

func _physics_process(_delta: float) -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		model.global_position.y = raycast.get_collision_point().y
