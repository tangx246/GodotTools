extends Node

func _ready() -> void:
	var Steam = Engine.get_singleton("Steam")
	if Steam:
		Steam.steamInitEx.call_deferred(0, true)

func get_steam() -> Object:
	if not Engine.has_singleton("Steam"):
		return null
	
	var Steam = Engine.get_singleton("Steam")
	if Steam and Steam.loggedOn():
		return Steam
	
	return null