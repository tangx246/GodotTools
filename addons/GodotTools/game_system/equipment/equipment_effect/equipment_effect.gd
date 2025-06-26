class_name EquipmentEffect
extends Resource

enum EffectType {
	BUFF,
	DEBUFF
}

func apply(root: Node) -> void:
	assert(false, "Unimplemented")
	
func unapply(root: Node) -> void:
	assert(false, "Unimplemented")
	
func get_text() -> String:
	assert(false, "Unimplemented")
	return "Unimplemented"

func get_effect_type() -> EffectType:
	return EffectType.BUFF

func _to_string() -> String:
	return Serializer.serialize(self)
