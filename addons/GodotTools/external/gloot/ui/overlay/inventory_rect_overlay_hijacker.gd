@tool
@icon("res://addons/gloot/images/icon_ctrl_inventory_grid.svg")
class_name InventoryRectOverlayHijacker
extends Node

@export var root: Node
## This overlay will be added as a child to the CtrlInventoryItemRect
@export var overlay: PackedScene
const overlay_name: String = "InventoryRectOverlay"

const CtrlInventoryItemRect = preload("uid://cw2nqo82wqs4i")

signal drag_end()

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	for child in root.find_children("", "Node", true, false):
		Signals.safe_connect(self, child.child_order_changed, _on_child_order_changed, CONNECT_DEFERRED)
	_on_child_order_changed()

var last_refreshed: int = -1
func _on_child_order_changed() -> void:
	await Engine.get_main_loop().process_frame
	if not is_inside_tree():
		return
	var current_tick: int = Engine.get_process_frames()
	if current_tick == last_refreshed:
		return
	last_refreshed = current_tick

	for child in root.find_children("", "Node", true, false):
		if child is CtrlInventoryItemRect:
			_override_texture_rect(child)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		drag_end.emit()

func _override_texture_rect(child: CtrlInventoryItemRect) -> void:
	if child.find_child(overlay_name, true, false) != null:
		return
	var overlay_instance: Node = overlay.instantiate()
	overlay_instance.name = overlay_name
	child.add_child(overlay_instance)
	Signals.safe_connect(overlay_instance, child.grabbed, func(_pos):
		overlay_instance.hide()
	)

	Signals.safe_connect(overlay_instance, drag_end, overlay_instance.show)
