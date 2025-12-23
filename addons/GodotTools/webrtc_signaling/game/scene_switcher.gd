class_name MultiplayerSceneSwitcher
extends Node

@export var loading_screen: PackedScene

const GROUP: StringName = "MultiplayerSceneSwitcher"

signal all_peers_ready
var ready_peers: int

var load_screen: LoadScreen
var instantiated: Node
var currently_switching: bool = false

func _enter_tree() -> void:
	Signals.safe_connect(self, multiplayer.server_disconnected, _clear_loading_screen)

func _init() -> void:
	add_to_group(GROUP)

func _ready() -> void:
	get_level_spawner().spawn_function = _spawn_function

func _spawn_function(resource_path: String) -> Node:
	if not instantiated:
		printerr("Pre-instantiation state invalid. Loading screen appears to have failed")
		var new_scene: PackedScene = ResourceLoader.load(resource_path)
		instantiated = new_scene.instantiate()
	
	var store: Node = instantiated
	instantiated = null

	return store

## Returns true if scene has been changed. false if unsuccessful (probably because no multiplayer authority)
static func switch_scenes(node: Node, new_scene: PackedScene) -> bool:
	return get_instance(node)._switch_scenes_server(new_scene)

static func get_instance(node: Node) -> MultiplayerSceneSwitcher:
	return node.get_tree().get_first_node_in_group(GROUP)

func _switch_scenes_server(new_scene: PackedScene) -> bool:
	if not is_multiplayer_authority():
		return false
	
	_switch_scenes.call_deferred(new_scene)
	return true

func _switch_scenes(new_scene: PackedScene) -> void:
	if currently_switching:
		push_error("Currently switching scenes. Aborting")
		return
		
	currently_switching = true
	print("Switcing to scene: %s" % new_scene)
	_clear_gameRoot()

	ready_peers = 0
	var await_peers: Callable = func():
		push_warning("Awaiting for peers timed out")
		all_peers_ready.emit()
	var timer: SceneTreeTimer = get_tree().create_timer(60)
	timer.timeout.connect(await_peers, CONNECT_ONE_SHOT)
	start_scene_switch.rpc(new_scene.resource_path)
	
	if ready_peers < multiplayer.get_peers().size() + 1:
		await all_peers_ready
		if timer.timeout.is_connected(await_peers):
			timer.timeout.disconnect(await_peers)
	
	get_level_spawner().spawn(new_scene.resource_path)
	
	currently_switching = false

@rpc("any_peer", "call_local", "reliable")
func load_complete():
	ready_peers += 1
	var total_peers: int = (multiplayer.get_peers().size() + 1)
	print("Peer %d loaded. %d peers loaded. %d total peers" % [multiplayer.get_remote_sender_id(), ready_peers, total_peers])
	if ready_peers >= total_peers:
		all_peers_ready.emit()

@rpc("authority", "call_local", "reliable")
func start_scene_switch(resource_path: String) -> void:
	load_screen = loading_screen.instantiate()
	add_child(load_screen)
	await Engine.get_main_loop().process_frame
	
	var started := Time.get_ticks_usec()

	var gameroot: Node = get_gameroot()
	if gameroot.get_child_count() != 0:
		await get_gameroot().get_child(0).tree_exited
	
	load_screen.state = LoadScreen.State.LOADING_SCENE
	if not await await_resource_load(resource_path):
		return

	var new_scene: PackedScene = ResourceLoader.load_threaded_get(resource_path)	
	instantiated = new_scene.instantiate()
	load_screen.state = LoadScreen.State.INITIALIZING_EVERYTHING
	instantiated.ready.connect(func():
		print("Loaded in %f seconds" % ((Time.get_ticks_usec() - started) / 1000000.0))
		_clear_loading_screen()
	, CONNECT_ONE_SHOT)

	load_complete.rpc_id(get_multiplayer_authority())

func _clear_loading_screen() -> void:
	if load_screen:
		load_screen.queue_free()
		load_screen = null

func await_resource_load(resource_path: String) -> bool:
	var err := ResourceLoader.load_threaded_request(resource_path, "", true)
	if err:
		printerr("Error loading resource %s: %s" % [resource_path, err])
		return false

	var load_status: ResourceLoader.ThreadLoadStatus
	while true:
		load_status = ResourceLoader.load_threaded_get_status(resource_path)
		if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			break
		elif load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED or load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Failed to load resource %s: %s" % [resource_path, load_status])
			return false
		await Engine.get_main_loop().process_frame

	return true

static func back_to_main() -> void:
	Engine.get_main_loop().reload_current_scene()
	
func _clear_gameRoot() -> void:
	clear_children(get_gameroot())

func get_gameroot() -> Node:
	var level_spawner: MultiplayerSpawner = get_level_spawner()
	return level_spawner.get_node(level_spawner.spawn_path)

func get_level_spawner() -> MultiplayerSpawner:
	return get_tree().get_first_node_in_group("LevelSpawner")

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()
