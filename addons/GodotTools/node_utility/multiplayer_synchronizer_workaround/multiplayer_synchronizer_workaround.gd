## Workaround for https://github.com/godotengine/godot/issues/100873
class_name MultiplayerSynchronizerWorkaround
extends MultiplayerSynchronizer

@onready var root: Node = get_node(root_path)

# Maps NodePath to Variant
var resource_memory: Dictionary = {}

func _init() -> void:
	# 3170 years
	replication_interval = 99999999999
	delta_interval = 99999999999

func _enter_tree() -> void:
	if is_multiplayer_authority():
		for path: NodePath in replication_config.get_properties():
			resource_memory[path] = null

		get_tree().physics_frame.connect(tick)

func _exit_tree() -> void:
	if is_multiplayer_authority():
		get_tree().physics_frame.disconnect(tick)

func tick() -> void:
	for path: NodePath in replication_config.get_properties():
		var resource: Variant = root.get_node(path).get(path.get_subname(0))

		if resource_memory[path] != resource:
			resource_memory[path] = resource
			sync_property.rpc(path, resource)

@rpc("authority", "call_remote", "reliable")
func sync_property(path: NodePath, value: Variant) -> void:
	var node: Node = root.get_node(path)
	if not node:
		print("Node not found %s" % path)
		return
	
	node.set(path.get_subname(0), value)

	delta_synchronized.emit()