class_name GlootItemProvider
extends ItemProvider

@export var item_type : String
@export var root: Node:
	set(value):
		root = value
		_disconnect_signals()
		find_inventories()
		_connect_signals()

const KEY_STACK_SIZE = "stack_size"

func _ready() -> void:
	refresh_item_count()

func _enter_tree() -> void:
	await get_tree().process_frame
	_connect_signals()

func _exit_tree() -> void:
	_disconnect_signals()

func _connect_signals() -> void:
	for inventory in find_inventories():
		if not inventory.contents_changed.is_connected(refresh_item_count):
			inventory.contents_changed.connect(refresh_item_count)
		if not inventory.item_property_changed.is_connected(refresh_item_count.unbind(2)):
			inventory.item_property_changed.connect(refresh_item_count.unbind(2))

func _disconnect_signals() -> void:
	for inventory in find_inventories():
		if inventory.contents_changed.is_connected(refresh_item_count):
			inventory.contents_changed.disconnect(refresh_item_count)
		if inventory.item_property_changed.is_connected(refresh_item_count.unbind(2)):
			inventory.item_property_changed.disconnect(refresh_item_count.unbind(2))

func peek_item() -> InventoryItem:
	return _get_items().pop_front()

func use_item(count_requested: int) -> int:
	var item_count_used : int = 0
	
	var items = _get_items()
	for item in items:
		if item_count_used >= count_requested:
			break
		
		var stack_size : int = item.get_property(KEY_STACK_SIZE)
		var item_needed : int = count_requested - item_count_used
		
		item.set_property(KEY_STACK_SIZE, maxi(stack_size - item_needed, 0))
		if item.get_property(KEY_STACK_SIZE) == 0:
			item.get_inventory().remove_item(item)
		
		item_count_used = mini(item_count_used + stack_size, count_requested)
	
	return item_count_used

## Override this to provide custom logic for what items to provide
func should_provide_item(item: InventoryItem) -> bool:
	return item.get_property(InventoryItem.KEY_TYPE) == item_type

func _get_items() -> Array[InventoryItem]:
	var items : Array[InventoryItem] = []
	for inventory in find_inventories():
		for item in inventory.get_items():
			if should_provide_item(item):
				items.append(item)
	return items

func refresh_item_count():
	var count : int = 0
	
	var items = _get_items()
		
	for item in items:
		count = count + item.get_property(KEY_STACK_SIZE)
			
	item_count = count

func find_inventories() -> Array[Inventory]:
	var _inventories : Array[Inventory] = []
	_inventories.assign(root.find_children("", "Inventory", true, false))
	return _inventories
