class_name AudioStreamPlayerProcessModeSetter
extends Node

func _enter_tree() -> void:
	Signals.safe_connect(self, get_tree().node_added, _on_node_added)

func _on_node_added(node: Node) -> void:
	if node is AudioStreamPlayer3D or node is AudioStreamPlayer:
		node.process_mode = Node.PROCESS_MODE_PAUSABLE
