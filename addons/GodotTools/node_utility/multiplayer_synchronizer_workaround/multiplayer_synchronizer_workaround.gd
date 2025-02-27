## Workaround for https://github.com/godotengine/godot/issues/100873
class_name MultiplayerSynchronizerWorkaround
extends MultiplayerSynchronizer

@onready var root: Node = get_node(root_path)
@export var tick_rate: int = 1

@export_group("Sleepy ticks")
## If true, ticks will slow down when values haven't changed for a while
@export var sleepy_ticks: bool = true
## Tick rate when values haven't changed for a while
@export var sleepy_tick_rate: int = 10
## How many ticks before this synchronizer is considered sleepy
@export var sleepy_tick_threshold: int = 300

var original_tick_rate: int

# Maps NodePath to Variant
var resource_memory: Dictionary = {}
var properties: Array[NodePath]
var nodepath_to_cached_nodepath: Dictionary = {}

class CachedNodePath:
	var node: Node
	var path_subname: StringName
	var is_dictionary: bool

func _init() -> void:
	# 3170 years
	replication_interval = 99999999999
	delta_interval = 99999999999
	properties = replication_config.get_properties()
	_positionrotation_to_transform(properties)

	ticks = randi() % tick_rate
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

func _enter_tree() -> void:
	if is_multiplayer_authority():
		for path: NodePath in properties:
			resource_memory[path] = null

		if properties.size() > 0:
			get_tree().physics_frame.connect(tick.call_deferred)

func _exit_tree() -> void:
	if is_multiplayer_authority():
		if get_tree().physics_frame.is_connected(tick.call_deferred):
			get_tree().physics_frame.disconnect(tick.call_deferred)

# NodePath to Variant
var dirty_properties: Dictionary = {}
var ticks: int
var ticks_since_change: int
func tick() -> void:
	ticks = (ticks + 1) % tick_rate
	if ticks != 0:
		return
	
	dirty_properties.clear()
	for path: NodePath in properties:
		var cached: CachedNodePath = _get_cached_node_path(path)
		var resource: Variant = cached.node.get(cached.path_subname)

		if resource_memory[path] != resource:
			if cached.is_dictionary:
				resource_memory[path] = (resource as Dictionary).duplicate(true)
			else:
				resource_memory[path] = resource
			dirty_properties[path] = resource
				
	if not dirty_properties.is_empty():
		ticks_since_change = 0
		if tick_rate == sleepy_tick_rate:
			tick_rate = original_tick_rate
		
		sync_properties.rpc(dirty_properties)
	else:
		ticks_since_change += 1
		
		if sleepy_ticks and ticks_since_change > sleepy_tick_threshold:
			tick_rate = sleepy_tick_rate
			ticks = randi() % tick_rate

func _get_cached_node_path(path: NodePath) -> CachedNodePath:
	if not nodepath_to_cached_nodepath.has(path):
		var cached := CachedNodePath.new()
		cached.node = root.get_node(path)
		cached.path_subname = path.get_subname(0)
		cached.is_dictionary = cached.node.get(cached.path_subname) is Dictionary
		nodepath_to_cached_nodepath[path] = cached

	return nodepath_to_cached_nodepath[path]

@rpc("authority", "call_remote", "reliable")
func sync_properties(synced_properties: Dictionary) -> void:
	for path: NodePath in synced_properties:
		var value: Variant = synced_properties[path]
		var cached: CachedNodePath = _get_cached_node_path(path)
		var node: Node = cached.node
		if not node or not is_instance_valid(node):
			print("Node not found %s" % path)
			return
		
		node.set(cached.path_subname, value)

	delta_synchronized.emit()
