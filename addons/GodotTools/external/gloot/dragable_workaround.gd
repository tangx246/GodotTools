extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")

## Fixes a bug where CtrlDragable is left in an unusable state when scene switches occur
func _ready() -> void:
	await get_tree().process_frame
	
	Signals.safe_connect(self, get_tree().get_first_node_in_group(MultiplayerSceneSwitcher.GROUP).get_gameroot().child_order_changed, func():
		get_viewport().gui_cancel_drag()
		if not get_tree().current_scene:
			return
		for cl in get_tree().current_scene.find_children("", "CanvasLayer", false, false):
			push_warning("CanvasLayer found in current_scene root: %s. Usually caused by scene switching while dragging" % cl)
			cl.queue_free()
	)
