## Workaround for https://github.com/godotengine/godot/issues/100873
class_name MultiplayerSynchronizerWorkaround
extends MultiplayerSynchronizer

@onready var root: Node = get_node(root_path)

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

func _enter_tree() -> void:
	if is_multiplayer_authority():
		for path: NodePath in properties:
			resource_memory[path] = null
			
			if not get_tree().physics_frame.is_connected(tick):
				get_tree().physics_frame.connect(tick)

func _exit_tree() -> void:
	if is_multiplayer_authority():
		if get_tree().physics_frame.is_connected(tick):
			get_tree().physics_frame.disconnect(tick)

# NodePath to Variant
var dirty_properties: Dictionary = {}
func tick() -> void:
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
		sync_properties.rpc(dirty_properties)

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
