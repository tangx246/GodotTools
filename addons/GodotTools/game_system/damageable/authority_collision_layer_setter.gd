extends Node

@export var root : CollisionObject3D
@export_flags_3d_physics var authority_layer : int
@export_flags_3d_physics var no_authority_layer : int

func _ready() -> void:
	if is_multiplayer_authority():
		root.collision_layer = authority_layer
	else:
		root.collision_layer = no_authority_layer
