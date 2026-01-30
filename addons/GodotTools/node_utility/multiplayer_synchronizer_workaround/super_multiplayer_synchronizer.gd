extends Node

const COMPRESSION_METHOD: FileAccess.CompressionMode = FileAccess.COMPRESSION_ZSTD

var packets: Array[PackedByteArray] = []

func push_sync(msw: MultiplayerSynchronizerWorkaround, dirty_properties: Dictionary[NodePath, Variant]) -> void:
	packets.append(Packet.new(msw.get_path(), dirty_properties).serialize())

func _physics_process(_delta: float) -> void:
	tick.call_deferred()

func tick() -> void:
	if not packets.is_empty():
		var serialized: PackedByteArray = var_to_bytes(packets)
		var compressed: PackedByteArray = serialized.compress(COMPRESSION_METHOD)
		sync_properties.rpc(compressed, serialized.size())
		
		packets.clear()

@rpc("any_peer", "call_remote", "reliable")
func sync_properties(compressed: PackedByteArray, size: int) -> void:
	var serialized: PackedByteArray = compressed.decompress(size, COMPRESSION_METHOD)
	var received_packets: Array[PackedByteArray] = bytes_to_var(serialized)
	for raw_packet: PackedByteArray in received_packets:
		var packet: Packet = Packet.deserialize(raw_packet)
		var msw: MultiplayerSynchronizerWorkaround = get_node_or_null(packet.msw_path)
		if not msw or not is_instance_valid(msw) or not msw.is_inside_tree() or\
			not msw.root or not is_instance_valid(msw.root) or not msw.root.is_inside_tree():
			continue
		
		if multiplayer.get_remote_sender_id() != msw.get_multiplayer_authority():
			print("Received sync from non-authority %s" % msw.get_path())
			return
		
		for path: NodePath in packet.dirty_properties:
			_sync_property(msw, path, packet.dirty_properties)

func _sync_property(msw: MultiplayerSynchronizerWorkaround, path: NodePath, synced_properties: Dictionary):
	var value: Variant = synced_properties[path]
	msw.receive_sync(path, value)

class Packet extends RefCounted:
	var msw_path: NodePath
	var dirty_properties: Dictionary[NodePath, Variant]

	func _init(msw_path: NodePath, dirty_properties: Dictionary[NodePath, Variant]) -> void:
		self.msw_path = msw_path
		self.dirty_properties = dirty_properties

	func serialize() -> PackedByteArray:
		return var_to_bytes([msw_path, dirty_properties])
	
	static func deserialize(pba: PackedByteArray) -> Packet:
		var array = bytes_to_var(pba)
		return Packet.new(array[0], array[1])
