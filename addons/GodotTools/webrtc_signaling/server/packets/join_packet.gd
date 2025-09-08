class_name JoinPacket 
extends RefCounted

@export var lobby: String
@export var host_name: String

static func deserialize(input: String) -> JoinPacket:
    return Serializer.deserialize(input)

func _to_string() -> String:
    return Serializer.serialize(self)
