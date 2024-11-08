@tool
class_name Metahuman extends Node3D

@export var skeleton : Skeleton3D
## For each node path key, the specified child index will be enabled
@export var nodePathsToChildIndex : Dictionary
## For each node path key that is a ShaderMaterialColorSetter, the specified color will be set
@export var colorPickerNodePathToColors : Dictionary
@export_category("Refresh Visibility After Changing Node Paths / Indices")
@export var refreshVisibility : bool : 
	set(val):
		refresh()

func _ready():
	refresh.call_deferred()

func _set_skeletons():
	var meshes = find_children("", "MeshInstance3D", true, false)
	var skeleton_path := skeleton.get_path()
	for mesh : MeshInstance3D in meshes:
		mesh.skeleton = skeleton_path
		
func _set_colors():
	if not Engine.is_editor_hint():
		for colorPickerNodePath in colorPickerNodePathToColors:
			var colorSetter : ShaderMaterialColorSetter = get_node(colorPickerNodePath)
			colorSetter.set_color(colorPickerNodePathToColors[colorPickerNodePath])

func refresh():
	if not is_inside_tree():
		return
	
	_set_skeletons()
	_set_colors()
	for nodePath in nodePathsToChildIndex:
		var node = get_node(nodePath)
		var index = nodePathsToChildIndex[nodePath]
		var i = 0
		for child : Node3D in node.get_children():
			child.visible = i == index
			i = i + 1
