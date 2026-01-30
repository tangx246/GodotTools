## Deprecated. Should use OnDemandPathSpawner instead
class_name OnDemandPathSpawner
extends Node3D

@export_file var scene_path: String
@onready var multiplayer_spawner : MultiplayerSpawner = get_tree().get_first_node_in_group("scene_spawner")

## Spawns a scene given the path. If the path is not given, uses exported scene_path
func spawn(path: String = "", offset: Vector3 = Vector3.ZERO, rotation_override: Vector3 = Vector3.INF, position_override: Vector3 = Vector3.INF) -> void:
	if path.is_empty():
		path = scene_path

	var rot: Vector3 = rotation_override if rotation_override != Vector3.INF else global_rotation
	var pos: Vector3 = position_override if position_override != Vector3.INF else global_position
	_spawn_entity.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, path, pos, rot, offset)

@rpc("any_peer", "reliable", "call_local")
func _spawn_entity(path: String, pos: Vector3, rot: Vector3, offset: Vector3) -> void:
	var scene: PackedScene = load(path)
	var instantiated: Node3D = scene.instantiate()
	instantiated.position = pos
	instantiated.rotation = rot
	instantiated.position += offset
	multiplayer_spawner.add_child(instantiated, true)
