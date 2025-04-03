class_name EquipmentEffect
extends Resource

func apply(root: Node) -> void:
	printerr("Unimplemented")
	
func unapply(root: Node) -> void:
	printerr("Unimplemented")
	
func get_text() -> String:
	return "Unimplemented"

func _to_string() -> String:
	return Serializer.serialize(self)
