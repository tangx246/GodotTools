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
	Signals.safe_connect(self, gameRoot.child_order_changed, _on_child_order_changed)
	Signals.safe_connect(self, multiplayer.peer_disconnected, _on_peer_disconnected)
	
func _exit_tree() -> void:
	for child in decorative_items:
		child.queue_free()
	
func _on_child_order_changed() -> void:
	if gameRoot.get_child_count() > 0:
		for child in decorative_items:
			if child.get_parent() == self:
				remove_child(child)

func _on_peer_disconnected(peer_id: int) -> void:
	if peer_id == MultiplayerPeer.TARGET_PEER_SERVER:
		for child in decorative_items:
			if child.get_parent() != self:
				add_child(child)
