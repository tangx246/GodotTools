extends Node

signal notification(value: Notification)

func emit(message: String, custom_toast_scene: String = "") -> void:
	_emit_rpc.rpc(message, custom_toast_scene)

@rpc("any_peer", "call_local", "reliable")
func _emit_rpc(message: String, custom_toast_scene: String) -> void:
	var _notif: Notification = Notification.new()
	_notif.message = message
	_notif.custom_toast_scene = custom_toast_scene
	notification.emit(_notif)
