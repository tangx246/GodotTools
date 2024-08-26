@tool
class_name FollowTarget
extends Node3D

@export var target: Node3D
@export var localOffset: Vector3

func _process(_delta: float) -> void:
	var translated = target.transform.translated_local(localOffset)
	rotation = target.rotation
	position = translated.origin
