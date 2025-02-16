## A workaround for https://github.com/godotengine/godot/issues/74327.
## Objects placed in scene cannot be directly in a MultiplayerSpawner's spawn_path
extends Node

@export var target_node : Node

func _ready():
	if is_multiplayer_authority():
		for child in get_children():
			child.owner = null
			child.reparent(target_node)

	queue_free()
