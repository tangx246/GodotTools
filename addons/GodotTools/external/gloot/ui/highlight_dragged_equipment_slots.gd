extends Node

@export var slot_style: StyleBox
@export var highlight_style: StyleBox
@export var root: Node

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")

func _ready() -> void:
	for slot: CtrlItemSlotEx in root.find_children("", "CtrlItemSlotEx"):
		Signals.safe_connect(self, CtrlDragable.dragable_grabbed, func(item_rect, _offset): _on_dragged(item_rect.item, slot))
		Signals.safe_connect(self, CtrlDragable.dragable_dropped, func(_a, _b, _c): _on_dropped(slot))
		
func _on_dragged(item: InventoryItem, slot: CtrlItemSlotEx):
	assert(slot._background_panel, "CtrlItemSlotEx is uninitialized")
	if slot.item_slot.can_hold_item(item):
		slot._background_panel.add_theme_stylebox_override("panel", highlight_style)

func _on_dropped(slot: CtrlItemSlotEx):
	slot._background_panel.add_theme_stylebox_override("panel", slot_style)
