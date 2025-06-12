## Allows the main menu scene to have scenes that will go away when the game is started
extends Node

@export var root: Node
@onready var gameRoot: Node = %GameRoot
@onready var client: WebsocketSignalingClient = root.find_children("", "WebsocketSignalingClient")[0]

var decorative_items: Array[Node]
func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	decorative_items = get_children()
	gameRoot.child_order_changed.connect(_on_child_order_changed, CONNECT_ONE_SHOT)
	client.disconnected.connect(_on_server_disconnected)
	
func _exit_tree() -> void:
	if gameRoot.child_order_changed.is_connected(_on_child_order_changed):
		gameRoot.child_order_changed.disconnect(_on_child_order_changed)
	if client.disconnected.is_connected(_on_server_disconnected):
		client.disconnected.disconnect(_on_server_disconnected)
		
	for child in decorative_items:
		child.queue_free()
	
func _on_child_order_changed() -> void:
	if gameRoot.get_child_count() > 0:
		for child in decorative_items:
			if child.get_parent() == self:
				remove_child(child)
				
func _on_server_disconnected() -> void:
	if get_child_count() == 0:
		for child in decorative_items:
			if child.get_parent() != self:
				add_child(child)
