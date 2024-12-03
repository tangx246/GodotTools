class_name Damageable
extends Node

@export var current_hp: float:
	get:
		return current_hp
	set(value):
		var prev_hp = current_hp
		current_hp = value
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

signal current_hp_changed(prevValue:float, value: float)
signal max_hp_changed(prevValue:float, value: float)
signal current_hp_changed_by_source(prevValue: float, value: float, source: Node)
signal died()
signal revived()
signal hp_changed()

func _ready():
	current_hp_changed.connect(func(_a, _b): hp_changed.emit())
	current_hp_changed.connect(_death_check)
	max_hp_changed.connect(func(_a, _b): hp_changed.emit())
	
	current_hp = current_hp
	max_hp = max_hp

func _death_check(prev_hp: float, current_hp: float):
	if current_hp <= 0 and prev_hp > 0:
		died.emit()
	elif current_hp > 0 and prev_hp <= 0:
		revived.emit()

func is_dead() -> bool:
	return current_hp <= 0

func damage(amount: float, source: Node = null):
	var prev_value = current_hp
	current_hp = maxf(current_hp - amount, 0)
	
	if source:
		current_hp_changed_by_source.emit(prev_value, current_hp, source)
