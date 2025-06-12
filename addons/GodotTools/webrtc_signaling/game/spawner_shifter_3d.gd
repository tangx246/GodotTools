class_name SpawnerShifter3D
extends SpawnerShifter

## Shifts the spawned thing in a direction * distance * index
@export var direction: Vector3 = Vector3.FORWARD
@export var distance: float = 1
var index: int = 0

func shift(node: Node):
	if node is not Node3D:
		printerr("Node %s is not a Node3D" % node.get_path()) 
		return

	var node3d = node as Node3D
	node3d.position += direction * distance * index
	index += 1
