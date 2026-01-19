@abstract
class_name ConsumableEffect
extends Resource

func apply(consumer: Node):
	printerr("Unimplemented")

func get_text() -> String:
	return "Unimplemented"

func _to_string() -> String:
	return Serializer.serialize(self)
