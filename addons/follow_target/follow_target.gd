@tool
class_name FollowTarget
extends Node3D

@export var target: Node3D
@export var localOffset: Vector3

func _physics_process(_delta: float) -> void:
	var translated = target.global_transform.translated_local(localOffset)
	global_rotation = target.global_rotation
	global_position = translated.origin
