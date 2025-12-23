@tool
class_name Metahuman extends Node3D

@export var skeleton : Skeleton3D
## For each node path key, the specified child index will be enabled
@export var nodePathsToChildIndex : Dictionary[NodePath, int]
## For each node path key that is a ShaderMaterialColorSetter, the specified color will be set
@export var colorPickerNodePathToColors : Dictionary[NodePath, Color]
@export_category("Refresh Visibility After Changing Node Paths / Indices")
@export var refreshVisibility : bool : 
	set(val):
		refresh()

var nodePathToResourcePath: Dictionary[NodePath, Array] = {}

func _ready():
	refresh.call_deferred()

	if Engine.is_editor_hint():
		return

	for nodePath in nodePathsToChildIndex:
		var node: Node = get_node(nodePath)
		var node_children: Array[Node] = node.get_children()
		nodePathToResourcePath[nodePath] = []
		for child: Node in node.get_children():
			assert(not child.scene_file_path.is_empty(), "Child path should be an instantiated scene")
			nodePathToResourcePath[nodePath].append(child.scene_file_path)
			child.queue_free()

func _set_skeletons():
	var meshes = find_children("", "MeshInstance3D", true, false)
	var skeleton_path := skeleton.get_path()
	for mesh : MeshInstance3D in meshes:
		var current_skeleton: Skeleton3D = mesh.get_node(mesh.skeleton)
		if not Engine.is_editor_hint():
			current_skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL
			current_skeleton.process_mode = Node.PROCESS_MODE_DISABLED

		mesh.skeleton = skeleton_path
		
func _set_colors():
	if not Engine.is_editor_hint():
		for colorPickerNodePath in colorPickerNodePathToColors:
			var colorSetter : ShaderMaterialColorSetter = get_node(colorPickerNodePath)
			colorSetter.set_color(colorPickerNodePathToColors[colorPickerNodePath])

func refresh():
	await TreeSync.wait_for_inside_tree(self)
	
	if Engine.is_editor_hint():
		_refresh_editor()
		return

	for nodePath in nodePathsToChildIndex:
		var node = get_node(nodePath)
		var index = nodePathsToChildIndex[nodePath]
		for child: Node3D in node.get_children():
			child.queue_free()

		if index >= 0:
			var loaded: PackedScene = load(nodePathToResourcePath[nodePath][index])
			var instantiated: Node = loaded.instantiate()
			node.add_child(instantiated)

	_set_skeletons()
	_set_colors()

func _refresh_editor() -> void:
	_set_skeletons()
	_set_colors()

	for nodePath in nodePathsToChildIndex:
		var node = get_node(nodePath)
		var index = nodePathsToChildIndex[nodePath]
		var i = 0
		for child : Node3D in node.get_children():
			child.visible = i == index
			i = i + 1
