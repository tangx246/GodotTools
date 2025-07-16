class_name PercentageDamageModifier
extends DamageModifier

## Amount to modify (e.g. 0.5 turns 10 damage into 5). Maps a collision_index (e.g. headshots) to damage reduction
@export var damage_modifiers: Array[IndexedDamageModifier]
## The default collision_index to use when the collision_shape_index is not found
@export var default_collision_index: int = 0
## If false, healing is also affected
@export var only_affect_damage: bool = true

## Maps collision_index: int to damage_modifier: float
var damage_modifiers_dict: Dictionary

func _enter_tree() -> void:
	damage_modifiers_dict = {}
	for modifier in damage_modifiers:
		damage_modifiers_dict[modifier.collision_index] = modifier.modifier

func get_damage(damage: float, source: Node, collision_shape_index: int) -> float:
	if damage > 0 and only_affect_damage:
		var damage_modifier: float = get_damage_modifier(collision_shape_index)
		damage_modifier = maxf(damage_modifier - _get_damage_penetration(source), 0)
		
		return (1 - damage_modifier) * damage
	else:
		return damage

func get_damage_modifier(collision_shape_index: int) -> float:
	var damage_modifier: float = 0
	if damage_modifiers_dict.has(collision_shape_index):
		damage_modifier = damage_modifiers_dict[collision_shape_index]
	else:
		damage_modifier = damage_modifiers_dict[default_collision_index]
	return damage_modifier
	
func set_damage_modifier(collision_shape_index: int, damage_modifier: float) -> void:
	damage_modifiers_dict[collision_shape_index] = damage_modifier
	damage_modifier_changed.emit()

func _get_damage_penetration(source: Node) -> float:
	var damage_penetration: float = 0
	if source:
		var flat_penetrations: Array[FlatPercentageDamageModifierPenetration] = []
		flat_penetrations.assign(source.find_children("", "FlatPercentageDamageModifierPenetration"))
		for flat_penetration in flat_penetrations:
			damage_penetration += flat_penetration.penetration
	return damage_penetration
