extends Node

var gameRoot : Node

func _ready():
	gameRoot = get_tree().get_first_node_in_group("GameRoot")

## Returns true if scene has been changed. false if unsuccessful (probably because no multiplayer authority)
func switch_scenes(new_scene : PackedScene) -> bool:
	if not is_multiplayer_authority():
		return false
	
	for child in gameRoot.get_children():
		gameRoot.remove_child(child)
		child.queue_free()
	var instantiated := new_scene.instantiate()
	gameRoot.add_child(instantiated, true)
	
	return true
