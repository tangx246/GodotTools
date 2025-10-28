class_name Toast
extends Control

@export var fade_time: float = 1.0
## How long to stay visible for
@export var visible_for: float = 3.0
## If this node is not a node that can have its text set, aim for this instead
@export var toast_text: NodePath

var timer: Timer
func _ready() -> void:
	await get_tree().create_timer(visible_for).timeout
	_fade_out()

func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_time)
	await tween.finished
	queue_free()

func toast(notification: Notification) -> void:
	if "text" in self:
		set("text", notification.message)
	elif toast_text and has_node(toast_text):
		var toast_text_node: Node = get_node(toast_text)
		if "text" in toast_text_node:
			toast_text_node.set("text", notification.message)
		else:
			push_error("Unable to set toast text for %s" % toast_text)
	else:
		push_error("Unable to handle toast %s" % get_path())
