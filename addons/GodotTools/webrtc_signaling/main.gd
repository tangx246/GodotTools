extends Node

@export var gameScene: PackedScene

func _ready() -> void:
	print_orphan_nodes.call_deferred()
