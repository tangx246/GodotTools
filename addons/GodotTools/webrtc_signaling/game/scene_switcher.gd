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
	clients_cleared_children = 0
	_clear_children_rpc.rpc()
	if multiplayer.get_peers().size() > 0:
		get_tree().create_timer(5).timeout.connect(func(): all_clients_cleared.emit())
		await all_clients_cleared
	await _clear_children()
	
	var instantiated := new_scene.instantiate()
	gameRoot.add_child(instantiated, true)

@rpc("authority", "call_remote", "reliable")
func _clear_children_rpc():
	await _clear_children()
	_finished_clearing_children_rpc.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)

@rpc("any_peer", "call_remote", "reliable")
func _finished_clearing_children_rpc():
	clients_cleared_children += 1
	print("Clients cleared: %s" % clients_cleared_children)
	if clients_cleared_children >= multiplayer.get_peers().size():
		all_clients_cleared.emit()

func _clear_children():
	# We have to slowly clear things under MultiplayerSpawners due to some mysterious Godot crash bug
	await _delete_node_list(gameRoot.find_children("", "StaticBody3D", true, false), 9999999999)
	await _delete_node_list(gameRoot.find_children("", "PhysicsBody3D", true, false))
	await _delete_node_list(gameRoot.get_children())

func _delete_node_list(children: Array[Node], chunk: int = 1):
	var deleted: int = 0
	for i in range(children.size() - 1, -1, -1):
		deleted += 1
		var spawner = children[i]

		# Looped items may not be there, apparently. Another Godot bug?
		if not spawner:
			continue

		spawner.queue_free()

		if deleted >= chunk:
			await get_tree().physics_frame
			await get_tree().process_frame
			deleted = 0

	await get_tree().physics_frame
	await get_tree().process_frame