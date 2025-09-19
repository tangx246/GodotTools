## Class that allows an embedded Node with visibility to respect its parent's visibility
class_name EmbeddedUI

static func attach(node: Node, visible_only: bool = true, parent_getter: Callable = func(node): return node.get_parent()) -> void:
	assert("visible" in node, "Node needs to have the visible property")
	assert("visibility_changed" in parent_getter.call(node), "Node parent should have visibility_changed")
	Signals.safe_connect(node, parent_getter.call(node).visibility_changed, func():
			_on_node_parent_visibility_changed(node, visible_only, parent_getter))
	_on_node_parent_visibility_changed(node, visible_only, parent_getter)

static func _on_node_parent_visibility_changed(node: Node, visible_only: bool, parent_getter: Callable) -> void:
	if (not visible_only) or node.visible:
		var _parent = parent_getter.call(node)
		var _parent_visibility: bool
		if _parent is CanvasItem:
			_parent_visibility = _parent.is_visible_in_tree()
		else:
			_parent_visibility = _parent.visible

		node.visible = _parent_visibility
