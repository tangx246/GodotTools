class_name Multiprocess
extends Node

@onready var clientui: Node = $".."

const GROUP: StringName = "Multiprocess"
const PATTERN: String = "[Signaling] Joined lobby "
const AUTOHOST_PARAM: String = "--autohost"
const SINGLEPLAYER_PARAM: String = "--singleplayer"

var local_instance_single_player: bool = false
var first_peer_id: int = -1

func is_multiprocess_instance() -> bool:
	return AUTOHOST_PARAM in OS.get_cmdline_args()
	
func is_multiprocess_instance_running() -> bool:
	return not output.is_empty()

static func is_local_instance_single_player(root: Node) -> bool:
	return get_first_instance(root).local_instance_single_player

static func is_multiprocess_instance_single_player() -> bool:
	return SINGLEPLAYER_PARAM in OS.get_cmdline_args()

static func get_first_instance(root: Node) -> Multiprocess:
	return root.get_tree().get_first_node_in_group(GROUP)

static func is_rpc_safe(root: Node) -> bool:
	return get_first_instance(root).is_multiprocess_instance()

func _enter_tree() -> void:
	add_to_group(GROUP)
	
	if is_multiprocess_instance():
		await get_tree().process_frame
		if not is_inside_tree():
			return
		var single_player: bool = is_multiprocess_instance_single_player()
		print("Multiprocess Server started. Autohosting. Singleplayer: %s" % single_player)
		clientui._on_start_pressed(single_player)

		var timer: Timer = Timer.new()
		timer.wait_time = 10
		timer.autostart = true
		timer.timeout.connect(func(): print("FPS: %s" % Performance.get_monitor(Performance.Monitor.TIME_FPS)))
		add_child(timer)
		
		multiplayer.peer_connected.connect(_on_peer_connected, CONNECT_ONE_SHOT)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int):
	first_peer_id = id

func _on_peer_disconnected(id: int):
	if multiplayer.get_peers().size() <= 0 or id == first_peer_id:
		print("No more peers in multiprocess instance or first peer %s left. Quitting" % id)
		get_tree().quit()

func _exit_tree() -> void:
	print("Multiprocess exiting tree")
	kill_headless_process()
	
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)

	if stdio_observer and stdio_observer.is_started():
		stdio_observer.wait_to_finish()
	if stderr_observer and stderr_observer.is_started():
		stderr_observer.wait_to_finish()

func _process_observer(pipe: FileAccess, is_error: bool) -> void:
	while pipe.is_open() and pipe.get_error() == OK:
		var line: String = pipe.get_line()
		if is_error:
			printerr("[Multiprocess] %s" % line)
		else:
			print("[Multiprocess] %s" % line)

		if line.begins_with(PATTERN):
			_on_server_created.call_deferred(line.trim_prefix(PATTERN))

	print("Process observer complete. %s" % pipe.get_error())
	kill_headless_process()

func kill_headless_process():
	if is_multiprocess_instance_running():
		var pid: int = output["pid"]
		print("Killing headless process %s" % pid)
		OS.kill(pid)
		output = {}
		stdio_observer.wait_to_finish()
		stderr_observer.wait_to_finish()

var output: Dictionary
var stdio_observer: Thread
var stderr_observer: Thread
func start_headless_process(single_player: bool):
	kill_headless_process()
	
	var params: Array[String] = ["--headless", AUTOHOST_PARAM]
	if single_player:
		params.append(SINGLEPLAYER_PARAM)
	output = OS.execute_with_pipe(OS.get_executable_path(), params)
	local_instance_single_player = single_player
	stdio_observer = Thread.new()
	stdio_observer.start(_process_observer.bind(output["stdio"], false))
	stderr_observer = Thread.new()
	stderr_observer.start(_process_observer.bind(output["stderr"], true))

func _on_server_created(lobby: String):
	clientui.room.text = lobby
	
	var single_player: bool = is_local_instance_single_player(self)
	clientui._on_join_pressed(single_player)
