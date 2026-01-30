## Workaround for https://github.com/godotengine/godot/issues/100873
class_name MultiplayerSynchronizerWorkaround
extends MultiplayerSynchronizer

var root: Node
@export var tick_rate: int = 1

@export_group("Interpolation")
## If true, received values will be interpolated instead of applied directly.
## This smooths out network jitter for physics objects like ragdolls.
@export var interpolate: bool = false
## Speed of interpolation. Higher = faster catch-up to target values.
@export var interpolation_speed: float = 20.0

## Stores target values for interpolation (NodePath -> Variant)
var interpolation_targets: Dictionary[NodePath, Variant] = {}
## Stores current interpolated values (NodePath -> Variant)
var interpolation_currents: Dictionary[NodePath, Variant] = {}

@export_group("Sleepy ticks")
## If true, ticks will slow down when values haven't changed for a while
@export var sleepy_ticks: bool = true
## Tick rate when values haven't changed for a while
@export var sleepy_tick_rate: int = 10
## How many ticks before this synchronizer is considered sleepy
@export var sleepy_tick_threshold: int = 300

var original_tick_rate: int

const COMPRESSION_METHOD = FileAccess.COMPRESSION_ZSTD

# Maps NodePath to Variant
var properties: Array[NodePath]
var cached_nodepaths: Array[CachedNodePath]
var nodepath_to_cached_nodepaths: Dictionary[NodePath, CachedNodePath] = {}

class CachedNodePath extends RefCounted:
	var node_path: NodePath
	var node: Node
	var path_subname: StringName
	var is_dictionary: bool:
		set(value):
			is_dictionary = value
			if is_dictionary:
				resource_returner = get_resource_dictionary
			else:
				resource_returner = get_resource
	var resource_returner: Callable
	var memory: Variant
	
	func _init() -> void:
		resource_returner = get_resource
	
	func get_resource(resource: Variant) -> Variant:
		return resource
		
	func get_resource_dictionary(resource: Variant) -> Variant:
		# resource is a Dictionary
		return resource.duplicate(true)

func _init() -> void:
	# 3170 years
	replication_interval = 99999999999
	delta_interval = 99999999999
	properties = replication_config.get_properties()
	_positionrotation_to_transform(properties)

	tick_shift = randi() % 10000
	original_tick_rate = tick_rate

func _positionrotation_to_transform(node_paths: Array[NodePath]):
	# Concatenated name (StringName) to Array[int]
	var indices: Dictionary = {}
	for i in range(node_paths.size()):
		var item: NodePath = node_paths[i]
		var concatenated_name: StringName = item.get_concatenated_names()
		if not indices.has(concatenated_name):
			indices[concatenated_name] = []
		
		if item.get_subname(0) == "position" or item.get_subname(0) == "rotation":
			indices[concatenated_name].append(i)
	
	for key: StringName in indices:
		if indices[key].size() == 2:
			for i in range(indices[key].size() - 1, -1, -1):
				node_paths.remove_at(i)
				
			var transform_nodepath: NodePath = NodePath("%s:transform" % key)
			node_paths.append(transform_nodepath)

func _ready() -> void:
	if process_mode == PROCESS_MODE_INHERIT:
		process_mode = Node.PROCESS_MODE_PAUSABLE
	root = get_node(root_path)

	# Disable _process by default - only enable when interpolating
	set_process(false)

	for path: NodePath in properties:
		var cached := CachedNodePath.new()
		cached.node_path = path
		cached.node = root.get_node(path)
		cached.path_subname = path.get_subname(0)
		cached.is_dictionary = cached.node.get(cached.path_subname) is Dictionary
		cached.memory = null
		cached_nodepaths.append(cached)
		nodepath_to_cached_nodepaths[path] = cached

	if is_multiplayer_authority():
		if properties.size() > 0:
			Signals.safe_connect(self, Engine.get_main_loop().physics_frame, tick, CONNECT_DEFERRED)

# NodePath to Variant
var dirty_properties: Dictionary[NodePath, Variant] = {}
var ticks_since_change: int
var tick_shift: int
func tick() -> void:
	if ((Engine.get_physics_frames() + tick_shift) % tick_rate) != 0:
		return

	if not is_inside_tree() or not can_process():
		return
	
	_do_compare()
				
	if not dirty_properties.is_empty():
		ticks_since_change = 0
		if tick_rate == sleepy_tick_rate:
			tick_rate = original_tick_rate
		
		SuperMultiplayerSynchronizer.push_sync(self, dirty_properties)
		#sync_properties.rpc(_compress(dirty_properties))
		dirty_properties.clear()
	else:
		ticks_since_change += 1
		
		if sleepy_ticks and ticks_since_change > sleepy_tick_threshold:
			tick_rate = sleepy_tick_rate

func _compress(dict: Dictionary[NodePath, Variant]) -> PackedByteArray:
	var original: PackedByteArray = var_to_bytes(dict)
	var compressed: PackedByteArray = original.compress(COMPRESSION_METHOD)
	return compressed

func _do_compare() -> void:
	for cached: CachedNodePath in cached_nodepaths:
		var resource: Variant = _get_resource(cached)

		_compare(resource, cached)
			
func _compare(actual: Variant, cached: CachedNodePath) -> void:
	if cached.memory != actual:
		cached.memory = cached.resource_returner.call(actual)
		_refresh_cache_and_update(cached, cached.resource_returner.call(actual))

func _refresh_cache_and_update(cached: CachedNodePath, actual: Variant) -> void:
	dirty_properties[cached.node_path] = actual

func _get_resource(cached: CachedNodePath) -> Variant:
	return cached.node.get(cached.path_subname)

@rpc("authority", "call_remote", "reliable")
func sync_properties(compressed: PackedByteArray) -> void:
	var synced_properties: Dictionary[NodePath, Variant] = bytes_to_var(compressed.decompress(1024, COMPRESSION_METHOD))
	for path: NodePath in synced_properties:
		_sync_property(path, synced_properties)

func _sync_property(path: NodePath, synced_properties: Dictionary):
	var value: Variant = synced_properties[path]
	var cached: CachedNodePath = nodepath_to_cached_nodepaths[path]
	var node: Node = cached.node
	if not node or not is_instance_valid(node):
		print("Node not found %s" % path)
		return
	
	node.set.call_deferred(cached.path_subname, value)
	delta_synchronized.emit.call_deferred()

## Called by SuperMultiplayerSynchronizer to receive synced values.
## If interpolation is enabled, stores target values instead of applying directly.
func receive_sync(path: NodePath, value: Variant) -> void:
	var node: Node = root.get_node_or_null(path)
	if not node or not is_instance_valid(node) or not node.is_inside_tree():
		return

	var property_name: StringName = path.get_subname(0)

	if interpolate:
		interpolation_targets[path] = value
		# Initialize current value if not present
		if not interpolation_currents.has(path):
			interpolation_currents[path] = value
		# Enable _process for interpolation
		if not is_processing():
			set_process(true)
	else:
		node.set(property_name, value)

	delta_synchronized.emit()

func _process(delta: float) -> void:
	for path: NodePath in interpolation_targets:
		var node: Node = root.get_node_or_null(path)
		if not node or not is_instance_valid(node):
			continue

		var property_name: StringName = path.get_subname(0)
		var target: Variant = interpolation_targets[path]
		var current: Variant = interpolation_currents.get(path, target)
		var interpolated: Variant

		var t: float = clampf(delta * interpolation_speed, 0.0, 1.0)

		if target is Transform3D:
			var current_transform: Transform3D = current as Transform3D
			var target_transform: Transform3D = target as Transform3D
			# Orthonormalize bases before slerp to avoid quaternion conversion errors
			var current_basis := current_transform.basis.orthonormalized()
			var target_basis := target_transform.basis.orthonormalized()
			interpolated = Transform3D(
				current_basis.slerp(target_basis, t),
				current_transform.origin.lerp(target_transform.origin, t)
			)
		elif target is Vector3:
			interpolated = (current as Vector3).lerp(target as Vector3, t)
		elif target is Quaternion:
			interpolated = (current as Quaternion).slerp(target as Quaternion, t)
		else:
			# For other types, just set directly
			interpolated = target

		interpolation_currents[path] = interpolated
		node.set(property_name, interpolated)
