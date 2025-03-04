## Allows the main menu scene to have scenes that will go away when the game is started
extends Node

@onready var gameRoot: Node = %GameRoot

var decorative_items: Array[Node]
func _enter_tree() -> void:
	await get_tree().process_frame
	decorative_items = get_children()
	gameRoot.child_order_changed.connect(_on_child_order_changed)
	
func _exit_tree() -> void:
	if gameRoot.child_order_changed.is_connected(_on_child_order_changed):
		gameRoot.child_order_changed.disconnect(_on_child_order_changed)
		
	for child in decorative_items:
		child.queue_free()
	
func _on_child_order_changed() -> void:
	if gameRoot.get_child_count() > 0:
		for child in decorative_items:
			remove_child(child)
	# Empty gameRoot and no existing decorative items			
	elif get_child_count() == 0:
		for child in decorative_items:
			add_child(child)
