class_name EquipmentEffect
extends Resource

enum EffectType {
	BUFF,
	DEBUFF
}

func apply(root: Node) -> void:
	printerr("Unimplemented")
	
func unapply(root: Node) -> void:
	printerr("Unimplemented")
	
func get_text() -> String:
	return "Unimplemented"

func get_effect_type() -> EffectType:
	return EffectType.BUFF

func _to_string() -> String:
	return Serializer.serialize(self)
