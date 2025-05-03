class_name GlootItemSlotEquipmentEffect
extends Node

@export var root: Node
@onready var item_slots: Array[ItemSlot] = [] 

var effect_stack: Array[EquipmentEffect] = []

const KEY_EFFECTS: String = "effects"
const KEY_MAX_POSITIVE_EFFECTS: String = "positive_effect_slots"

func _ready() -> void:
	item_slots.assign(root.find_children("", "ItemSlot"))

func _enter_tree() -> void:
	await get_tree().process_frame
	for item_slot in item_slots:
		if not item_slot.item_equipped.is_connected(_on_item_equipped):
			item_slot.item_equipped.connect(_on_item_equipped)
		if not item_slot.cleared.is_connected(_on_item_unequipped):
			item_slot.cleared.connect(_on_item_unequipped)
	_refresh()

func _exit_tree() -> void:
	for item_slot in item_slots:
		if item_slot.item_equipped.is_connected(_on_item_equipped):
			item_slot.item_equipped.disconnect(_on_item_equipped)
		if item_slot.cleared.is_connected(_on_item_unequipped):
			item_slot.cleared.disconnect(_on_item_unequipped)

func _on_item_equipped() -> void:
	_refresh.call_deferred()

func _on_item_unequipped() -> void:
	_refresh.call_deferred()

var last_refreshed: int = -1
func _refresh() -> void:
	if last_refreshed == Engine.get_process_frames():
		return
	
	while effect_stack.size() > 0:
		var effect: EquipmentEffect = effect_stack.pop_back()
		effect.unapply(_get_root())

	for item_slot: ItemSlot in item_slots:
		var item: InventoryItem = item_slot.get_item()
		if item:
			var effects: Array[String] = []
			effects.assign(item.get_property(KEY_EFFECTS, []))
			for effect_path: String in effects:
				var effect: EquipmentEffect = load(effect_path)
				if effect:
					effect.apply(_get_root())
					effect_stack.append(effect)
				else:
					printerr("Unable to load effect: %s" % effect_path)

	last_refreshed = Engine.get_process_frames()

func _get_root() -> Node:
	if "root" in root:
		return root.root
	else:
		return root
