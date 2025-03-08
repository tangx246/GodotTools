class_name AudioStreamPlayerProcessModeSetter
extends Node

func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)

func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is AudioStreamPlayer3D or node is AudioStreamPlayer:
		node.process_mode = Node.PROCESS_MODE_PAUSABLE
