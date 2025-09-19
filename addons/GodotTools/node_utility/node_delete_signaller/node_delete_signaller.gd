class_name NodeDeleteSignaller
extends Node

signal predelete

func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        predelete.emit()
