class_name GlootItemSlotEquipmentEffect
extends Node

@export var root: Node
@export_group("Weapon System")
@export var weapon_system_class: StringName = "WeaponSystem"
@export var weapon_changed_signal: StringName = "gun_changed"
## Given an ItemSlot, is this both a WeaponSlot and is currently wielded
@export var is_wielded_weapon_slot: StringName = "is_weapon_slot_currently_wielded"
@export var is_weapon_slot: StringName = "is_weapon_slot"
@onready var item_slots: Array[ItemSlot] = []
@onready var weapon_system: Node = root.get_parent().find_children("", weapon_system_class).pop_front()

var effect_stack: Array[EquipmentEffect] = []

const KEY_EFFECTS: String = "effects"
const KEY_MAX_POSITIVE_EFFECTS: String = "positive_effect_slots"

func _ready() -> void:
	item_slots.assign(root.find_children("", "ItemSlot"))
	for item_slot in item_slots:
		Signals.safe_connect(self, item_slot.item_equipped, _on_item_equipped)
		Signals.safe_connect(self, item_slot.cleared, _on_item_unequipped)
	if weapon_system:
		assert(weapon_system.has_signal(weapon_changed_signal), "WeaponSystem must have %s signal" % weapon_changed_signal)
		assert(weapon_system.has_method(is_wielded_weapon_slot), "WeaponSystem must have %s method" % is_wielded_weapon_slot)
		assert(weapon_system.has_method(is_weapon_slot), "WeaponSystem must have %s method" % is_weapon_slot)
		Signals.safe_connect(self, weapon_system.get(weapon_changed_signal), _refresh.unbind(1), CONNECT_DEFERRED)
	_refresh.call_deferred()

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
		# Non-equipped weapons should be ignored
		if weapon_system and weapon_system.get(is_weapon_slot).call(item_slot) and not weapon_system.get(is_wielded_weapon_slot).call(item_slot):
			continue

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
