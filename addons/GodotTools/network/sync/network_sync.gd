extends Node

signal replicated_status(path: NodePath, timed_out: bool)

## Await this function to ensure that this node has been replicated on all clients
func replicated(node: Node) -> void:
	var count: int = 0
	var path: NodePath = node.get_path()
	var timer: SceneTreeTimer = get_tree().create_timer(30)
	var timed_out_func: Callable = func():
		replicated_status.emit(path, true)
	timer.timeout.connect(timed_out_func, CONNECT_ONE_SHOT)

	request_replication_status.rpc(node.get_path())

	while count < multiplayer.get_peers().size():
		var result: Array = await replicated_status
		var replicated_path: NodePath = result[0]
		if replicated_path == path:
			var timed_out: bool = result[1]
			if timed_out:
				break

			count += 1

	if timer.timeout.is_connected(timed_out_func):
		timer.timeout.disconnect(timed_out_func)
	#print("SUCCESS! Awaited all replications. Count: %s, Path: %s, Peers: %s" % [count, path, multiplayer.get_peers().size()])

@rpc("any_peer", "call_local", "reliable")
func request_replication_status(path: NodePath) -> void:
	var node: Node = get_node_or_null(path)
	var count: int = 0
	while not node and count < 30:
		await get_tree().create_timer(0.1).timeout
		node = get_node_or_null(path)
		count += 1

	if node:
		send_replication_status.rpc_id(multiplayer.get_remote_sender_id(), path)

@rpc("any_peer", "call_local", "reliable")
func send_replication_status(path: NodePath) -> void:
	replicated_status.emit(path, false)
