## Class that allows an embedded Node with visibility to respect its parent's visibility
class_name EmbeddedUI

static func attach(node: Node) -> void:
	assert("visible" in node, "Node needs to have the visible property")
	assert("visibility_changed" in node.get_parent(), "Node parent should have visibility_changed")
	Signals.safe_connect(node, node.get_parent().visibility_changed, func():
			_on_node_parent_visibility_changed(node))
	_on_node_parent_visibility_changed(node)

static func _on_node_parent_visibility_changed(node: Node) -> void:
	if node.visible:
		var _parent = node.get_parent()
		var _parent_visibility: bool
		if _parent is CanvasItem:
			_parent_visibility = _parent.is_visible_in_tree()
		else:
			_parent_visibility = _parent.visible

		if not _parent_visibility:
			node.visible = false
