class_name OnDemandPackedSceneSpawner
extends Node3D

@export var scene: PackedScene
@onready var multiplayer_spawner : MultiplayerSpawner = get_tree().get_first_node_in_group("scene_spawner")

func spawn() -> void:
	var instantiated = scene.instantiate()
	instantiated.transform = global_transform
	multiplayer_spawner.add_child(instantiated, true)
