class_name Selector
extends Node

@export var selected: Node:
	set(value):
		if selected:
			node_unselected.emit(selected)
		selected = value
		node_selected.emit(value)
signal node_selected(node: Node)
signal node_unselected(node: Node)

func _ready() -> void:
	Signals.safe_connect(self, get_tree().node_added, _connect_node)
	for node in get_tree().current_scene.find_children("", "Selectable2D"):
		_connect_node(node)
	
func _connect_node(node: Node) -> void:
	if node is Selectable2D:
		Signals.safe_connect(self, node.selected, _on_selected)
		
func _on_selected(root: Node) -> void:
	selected = root
