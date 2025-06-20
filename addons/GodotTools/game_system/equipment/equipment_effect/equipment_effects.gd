class_name EquipmentEffects
extends EquipmentEffect

@export var effects: Array[EquipmentEffect]
@export var effect_type: EffectType

func apply(root: Node) -> void:
	for effect in effects:
		effect.apply(root)
	
func unapply(root: Node) -> void:
	for i in range(effects.size() - 1, -1, -1):
		effects[i].unapply(root)
	
func get_text() -> String:
	var effect_texts: String = ", ".join(effects.map(func(effect: EquipmentEffect) -> String: return effect.get_text()))
	return "{resource_name}: {effect_texts}".format({
		"resource_name": resource_name,
		"effect_texts": effect_texts
	})

func get_effect_type() -> EffectType:
	return effect_type
