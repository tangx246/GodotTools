## Syncs an object's @export-ed variables across the network using Serializer
extends Node

const COMPRESSION: FileAccess.CompressionMode = FileAccess.COMPRESSION_ZSTD

## Attach to a Signal that emits when anything in the object changes. Should be called in _ready()
## If emit_recursive is true, emits the signal to every sub-Object's Signal that has ObjectSync attached
func attach(object_changed_signal: Signal, emit_recursive: bool = false) -> void:
	var object: Object = object_changed_signal.get_object()
	assert(object is Node, "Object must be a node")
	Signals.safe_connect(object, object_changed_signal, _sync.bind(object_changed_signal, emit_recursive))

func _sync(object_changed_signal: Signal, emit_recursive: bool) -> void:
	var object: Object = object_changed_signal.get_object()
	if not object.is_multiplayer_authority():
		return

	var data: String = Serializer.serialize(object)
	var data_bytes: PackedByteArray = var_to_bytes(data)

	_sync_rpc.rpc(object.get_path(), object_changed_signal.get_name(), data_bytes.compress(COMPRESSION), data_bytes.size(), emit_recursive)

	if emit_recursive:
		_emit_recursive(object, false)

@rpc("any_peer", "call_remote", "reliable")
func _sync_rpc(path: NodePath, signal_name: StringName, compressed_data_bytes: PackedByteArray, data_size: int, emit_recursive: bool) -> void:
	var data: String = bytes_to_var(compressed_data_bytes.decompress(data_size, COMPRESSION))
	
	var node: Node = get_node_or_null(path)
	if not node:
		push_error("Node %s not found" % path)
		return
	
	var sender: int = multiplayer.get_remote_sender_id()
	var object_authority: int = node.get_multiplayer_authority()
	if sender != object_authority:
		push_error("Only authority can sync. Sender: %s, Authority: %s" % [sender, object_authority])
		return
	
	if not node.has_signal(signal_name):
		push_error("Signal %s in %s not found" % [signal_name, node.get_path()])
		return

	Serializer.deserialize(data, node)    
	node.emit_signal(signal_name)

	if emit_recursive:
		_emit_recursive(node, false)

func _emit_recursive(root: Object, emit_root: bool) -> void:
	if emit_root:
		var signals: Array[Dictionary] = root.get_signal_list()
		for signal_list in signals:
			var signal_name: String = signal_list["name"]
			var sg: Signal = root.get(signal_name)
			if sg.is_connected(_sync):
				sg.emit()

	for property in root.get_property_list():
		if property["type"] != TYPE_OBJECT or property["name"] == "owner":
			continue

		# property["type"] == TYPE_OBJECT
		var object: Object = root.get(property["name"])
		if object != null:
			_emit_recursive(object, true)
