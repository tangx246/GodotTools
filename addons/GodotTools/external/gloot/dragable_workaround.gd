extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")

## Fixes a bug where CtrlDragable is left in an unusable state when scene switches occur
func _ready() -> void:
	await get_tree().process_frame
	
	if not _override():
		Signals.safe_connect(self, get_tree().tree_changed, _override)

func _override() -> bool:
	if not get_tree().get_first_node_in_group(MultiplayerSceneSwitcher.GROUP):
		return false
	
	Signals.safe_connect(self, get_tree().get_first_node_in_group(MultiplayerSceneSwitcher.GROUP).get_gameroot().child_order_changed, func():
		get_viewport().gui_cancel_drag()
		if not get_tree().current_scene:
			return
		for cl in get_tree().current_scene.find_children("", "CanvasLayer", false, false):
			if cl.get_child_count() > 0 and cl.get_child(0).get_child_count() > 0 and \
				cl.get_child(0).get_child(0) is CtrlInventoryItemRect:
				push_warning("CanvasLayer with draggable found in current_scene root: %s. Usually caused by scene switching while dragging" % cl)
				cl.queue_free()
	)
	Signals.safe_disconnect(self, get_tree().tree_changed, _override)
	return true
