class_name GlootInventoryDragResizer
extends Node

@export var field_dimensions: Vector2 = Vector2(32, 32)

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")

func _ready() -> void:
	Signals.safe_connect(self, CtrlDragable.dragable_grabbed, _draggable_grabbed, CONNECT_DEFERRED)

func _draggable_grabbed(node: CtrlDragable, _offset: Vector2) -> void:
	if not is_instance_valid(node) or node.is_queued_for_deletion() or not is_instance_valid(node.sub_preview) or node.sub_preview.is_queued_for_deletion():
		return

	var item: InventoryItem = node.item
	if not item:
		return

	node.sub_preview.size = Vector2(
		item.get_property(GridConstraint.KEY_WIDTH) * field_dimensions.x,
		item.get_property(GridConstraint.KEY_HEIGHT) * field_dimensions.y
	)
	
	var offset: Vector2 = (node.sub_preview.size / 2) * node.sub_preview.get_global_transform().get_scale()
	node.sub_preview.global_position = get_tree().current_scene.get_viewport().get_mouse_position() - offset
	CtrlDragable._grab_offset = offset
