class_name CtrlInventoryOverlay
extends Control

var item: InventoryItem:
	get():
		var parent = get_parent()
		if is_instance_valid(parent):
			if is_instance_valid(parent.item):
				return parent.item

		return null
signal refresh

func _ready() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		await tree_entered

	var ancestor: Node = get_parent()
	while ancestor != null and not ancestor is CtrlItemSlot:
		ancestor = ancestor.get_parent()
	if ancestor is CtrlItemSlot:
		Signals.safe_connect(self, ancestor.item_slot.item_equipped, refresh.emit)
		Signals.safe_connect(self, ancestor.item_slot.cleared, refresh.emit)
		
	if item and item.is_inside_tree():
		Signals.safe_connect(self, item.protoset_changed, refresh.emit)
		Signals.safe_connect(self, item.prototype_id_changed, refresh.emit)
		Signals.safe_connect(self, item.property_changed, refresh.emit.unbind(1))
