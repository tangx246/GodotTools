class_name LootTableFiller
extends Node

## If null, will search current parent for an inventory
@export var target_inventory : Inventory
@export var loot_table : Array[LootWeight]
@export var strategy : Strategy

var strat_impl

enum Strategy {
	ONCE, ## e.g. Apple: 0.1, Orange: 0.1. Will always get 1 item. 50% chance to get Apple, 50% chance to get Orange
	CUMULATIVE ## e.g. Apple: 0.1, Orange: 0.1. 10% chance to get 1 Apple, 10% chance to get 1 orange, 1% chance to get both an Apple and an Orange, 79% chance to get nothing
}

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	if not target_inventory:
		target_inventory = get_parent().find_children("", "Inventory")[0]

	if strategy == Strategy.ONCE:
		_spawn_once()
	elif strategy == Strategy.CUMULATIVE:
		_spawn_cumulative()
	else:
		printerr("Unimplemented")
		assert(false)

func _spawn_once():
	var total_weight : float = 0
	for loot_weight in loot_table:
		total_weight += loot_weight.weight
		
	var rand = randf_range(0, total_weight)
	var weight_so_far : float = 0
	for loot_weight in loot_table:
		if rand >= weight_so_far and rand <= weight_so_far + loot_weight.weight:
			_add_item(loot_weight.prototype_id)
			break
		weight_so_far += loot_weight.weight
	
func _spawn_cumulative():
	for loot_weight in loot_table:
		var rand = randf_range(0, 1)
		if rand <= loot_weight.weight:
			_add_item(loot_weight.prototype_id)

func _add_item(prototype_id: String):
	target_inventory.create_and_add_item(prototype_id)
