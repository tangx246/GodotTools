extends Node

var clients_cleared_children: int = 0
signal all_clients_cleared

## Returns true if scene has been changed. false if unsuccessful (probably because no multiplayer authority)
func switch_scenes(new_scene: PackedScene) -> bool:
	if not is_multiplayer_authority():
		return false
	
	_switch_scenes.call_deferred(new_scene)
	return true

func _switch_scenes(new_scene: PackedScene) -> void:
	_clear_gameRoot()
	
	var instantiated := new_scene.instantiate()
	get_game_root().add_child(instantiated, true)

func back_to_main() -> void:
	get_tree().reload_current_scene()
	
func _clear_gameRoot() -> void:
	clear_children(get_game_root())

func get_game_root() -> Node:
	return get_tree().get_first_node_in_group("GameRoot")

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()
