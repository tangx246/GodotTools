class_name CtrlInventoryOverlay
extends Control

var item: InventoryItem:
	get():
		return get_parent().item
signal refresh

func _ready() -> void:
	var ancestor: Node = get_parent()
	while ancestor != null and not ancestor is CtrlItemSlot:
		ancestor = ancestor.get_parent()
	if ancestor is CtrlItemSlot:
		Signals.safe_connect(self, ancestor.item_slot.item_equipped, refresh.emit)
		Signals.safe_connect(self, ancestor.item_slot.cleared, refresh.emit)
		
	if item:
		Signals.safe_connect(item, item.protoset_changed, refresh.emit)
		Signals.safe_connect(item, item.prototype_id_changed, refresh.emit)
		Signals.safe_connect(item, item.property_changed, refresh.emit.unbind(1))
