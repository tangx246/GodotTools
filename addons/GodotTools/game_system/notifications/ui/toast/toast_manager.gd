## Pops up a little thing that shows up for a moment and then disappears
class_name ToastManager
extends VBoxContainer

@export var toast_scene: PackedScene = preload("uid://bcux8ql5w7ns3")

func _ready() -> void:
	Signals.safe_connect(self, Notifications.notification, _on_notification)

func _on_notification(notif: Notification) -> void:
	var instantiated: Toast = toast_scene.instantiate() if notif.custom_toast_scene.is_empty() else load(notif.custom_toast_scene)
	instantiated.toast(notif)
	add_child(instantiated)
