extends Node

var gameRoot : Node

func _ready():
	gameRoot = get_tree().get_first_node_in_group("GameRoot")

## Returns true if scene has been changed. false if unsuccessful (probably because no multiplayer authority)
func switch_scenes(new_scene : PackedScene) -> bool:
	if not is_multiplayer_authority():
		return false
	
	_switch_scenes.call_deferred(new_scene)
	return true

func _switch_scenes(new_scene : PackedScene) -> void:
	_clear_children()
	
	var instantiated := new_scene.instantiate()
	gameRoot.add_child(instantiated, true)

func _clear_children():
	for child in gameRoot.get_children():
		gameRoot.remove_child(child)
		child.queue_free()
