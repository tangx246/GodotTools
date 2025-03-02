## Allows the main menu scene to have scenes that will go away when the game is started
extends Node

@onready var gameRoot: Node = %GameRoot

var decorative_items: Array[Node]
func _enter_tree() -> void:
	await get_tree().process_frame
	decorative_items = get_children()
	gameRoot.child_entered_tree.connect(_remove_decorative_items, CONNECT_ONE_SHOT)
	
func _exit_tree() -> void:
	if gameRoot.child_entered_tree.is_connected(_remove_decorative_items):
		gameRoot.child_entered_tree.disconnect(_remove_decorative_items)
	
func _remove_decorative_items(_node: Node) -> void:
	for child in decorative_items:
		child.queue_free()
