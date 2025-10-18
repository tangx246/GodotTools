class_name TreeSync

static func wait_for_inside_tree(node: Node) -> void:
	if not node.is_inside_tree():
		await node.tree_entered
