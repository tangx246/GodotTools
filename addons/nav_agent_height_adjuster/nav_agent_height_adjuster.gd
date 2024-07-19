class_name NavAgentHeightAdjuster
extends Node

@export var raycastSource : Node3D
@export var navAgent : NavigationAgent3D
@export var model : Node3D
@export var down : Vector3 = Vector3.DOWN
@export var ray_length : float = 1
@export_flags_3d_physics var raycast_mask : int = 1
@export var verbose : bool = false

func _physics_process(_delta):
	var space_state = get_tree().root.get_world_3d().direct_space_state
	var from : Vector3 = raycastSource.global_position + (down * 0.05)
	var to : Vector3 = from + down * ray_length
	
	var query = PhysicsRayQueryParameters3D.create(from, to, raycast_mask)
	var result = space_state.intersect_ray(query)
	if result.size() > 0:
		var intersect_point : Vector3 = result["position"]
		var distance_to_ground : float = from.distance_to(intersect_point)
		if verbose:
			print("Distance to ground: %s" % distance_to_ground)
		model.global_position = intersect_point
	else:
		push_warning("No ground detected")
