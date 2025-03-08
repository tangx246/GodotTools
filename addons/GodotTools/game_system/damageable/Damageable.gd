class_name Damageable
extends Node

@export var current_hp: float:
	get:
		return current_hp
	set(value):
		var prev_hp = current_hp
		current_hp = clampf(value, 0, max_hp)
		current_hp_changed.emit(prev_hp, value)
@export var max_hp: float:
	get:
		return max_hp
	set(value):
		var prev_hp = max_hp
		max_hp = value
		if current_hp < max_hp:
			current_hp = max_hp
		max_hp_changed.emit(prev_hp, value)

## An ordered list of damage modifiers to apply to all incoming damage
@export var damage_modifiers: Array[DamageModifier]

signal current_hp_changed(prevValue: float, value: float)
signal max_hp_changed(prevValue: float, value: float)
signal current_hp_changed_by_source(prevValue: float, value: float, source: Node)
signal died()
signal revived()
signal hp_changed()
signal current_hp_reduced()

func _enter_tree() -> void:
	current_hp_changed.connect(_on_current_hp_changed)
	current_hp_changed.connect(_death_check)
	max_hp_changed.connect(_on_max_hp_changed)
	
	current_hp = current_hp
	max_hp = max_hp

func _exit_tree() -> void:
	current_hp_changed.disconnect(_on_current_hp_changed)
	current_hp_changed.disconnect(_death_check)
	max_hp_changed.disconnect(_on_max_hp_changed)

func _on_current_hp_changed(prev: float, current: float) -> void:
	hp_changed.emit()
	if current < prev:
		current_hp_reduced.emit()

func _on_max_hp_changed(_prev: float, _current: float) -> void:
	hp_changed.emit()

func _death_check(prev_hp: float, current_hp: float):
	if current_hp <= 0 and prev_hp > 0:
		died.emit()
	elif current_hp > 0 and prev_hp <= 0:
		revived.emit()

func is_dead() -> bool:
	return current_hp <= 0

func _get_modified_damage(original_amount: float, source: Node, collision_shape_index: int) -> float:
	var amount: float = original_amount
	for modifier in damage_modifiers:
		amount = modifier.get_damage(amount, source, collision_shape_index)
	return amount

## Returns the calculated damage received by this Damageable
func damage(amount: float, source: Node = null, ignore_damage_modifiers: bool = false, collision_shape_index: int = 0) -> float:
	var modified_amount: float = amount if ignore_damage_modifiers else _get_modified_damage(amount, source, collision_shape_index)
	
	var prev_value = current_hp
	current_hp = current_hp - modified_amount
	
	if not source:
		source = get_parent()
	
	current_hp_changed_by_source.emit(prev_value, current_hp, source)

	return modified_amount
