## A workaround for https://github.com/godotengine/godot/issues/74327.
## Objects placed in scene cannot be directly in a MultiplayerSpawner's spawn_path
extends Node

@export var target_node : Node

func _ready():
	if multiplayer.is_server():
		for child in get_children():
			remove_child(child)
			target_node.add_child(child, true)

	queue_free()
