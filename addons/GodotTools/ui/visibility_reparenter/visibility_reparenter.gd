## Given a target, if the target becomes visible, reparent ourselves to it. Otherwise, go back to our original parent.
## This is useful for Controls (e.g. HUDs) that are usually visible and uninteractable, but can eventually be interacted with
class_name VisibilityReparenter
extends Control

@export var target: Control
var original_parent: Node

func _ready() -> void:
	original_parent = get_parent()
	Signals.safe_connect(self, target.visibility_changed, _on_target_visibility_changed)
	_on_target_visibility_changed.call_deferred()

func _on_target_visibility_changed():
	if target.visible:
		reparent(target)
	else:
		reparent(original_parent)
