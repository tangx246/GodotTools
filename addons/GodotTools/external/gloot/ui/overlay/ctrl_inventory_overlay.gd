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
	await Engine.get_main_loop().process_frame
	await TreeSync.wait_for_inside_tree(self)

	var ancestor: Node = get_parent()
	while ancestor != null and not ancestor is CtrlItemSlot:
		ancestor = ancestor.get_parent()
	if ancestor is CtrlItemSlot:
		Signals.safe_connect(self, ancestor.item_slot.item_equipped, refresh.emit, CONNECT_DEFERRED)
		Signals.safe_connect(self, ancestor.item_slot.cleared, refresh.emit, CONNECT_DEFERRED)
		
	if item and item.is_inside_tree():
		Signals.safe_connect(self, item.protoset_changed, refresh.emit, CONNECT_DEFERRED)
		Signals.safe_connect(self, item.prototype_id_changed, refresh.emit, CONNECT_DEFERRED)
		Signals.safe_connect(self, item.property_changed, refresh.emit.unbind(1), CONNECT_DEFERRED)
