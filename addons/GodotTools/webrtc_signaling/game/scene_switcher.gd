extends Node

var gameRoot: Node
var clients_cleared_children: int = 0
signal all_clients_cleared

func _ready():
	gameRoot = get_tree().get_first_node_in_group("GameRoot")

## Returns true if scene has been changed. false if unsuccessful (probably because no multiplayer authority)
func switch_scenes(new_scene: PackedScene) -> bool:
	if not is_multiplayer_authority():
		return false
	
	_switch_scenes.call_deferred(new_scene)
	return true

func _switch_scenes(new_scene: PackedScene) -> void:
	clear_children(gameRoot)
	
	var instantiated := new_scene.instantiate()
	gameRoot.add_child(instantiated, true)

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()
