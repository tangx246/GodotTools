@tool
class_name FollowTarget
extends Node3D

@export var target: Node3D
@export var localOffset: Vector3

@export_group("Editor Only")
@export var track_target_in_editor: bool = false

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if track_target_in_editor:
			track_target()
		return

	track_target()

func track_target():
	global_transform = target.global_transform.translated_local(localOffset)