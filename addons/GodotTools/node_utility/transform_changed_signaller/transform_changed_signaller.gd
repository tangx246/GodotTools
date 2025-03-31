class_name TransformChangedSignaller
extends Node3D

signal transform_changed

func _ready() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		transform_changed.emit()
