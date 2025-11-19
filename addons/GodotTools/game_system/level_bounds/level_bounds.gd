@tool
class_name LevelBounds
extends Area3D

@export var level_root: Node

## Signal emitted when a body exits the bounds of the level.
signal exited_bounds(body: Node)

func _ready() -> void:
	var meshes: Array[Node] = level_root.find_children("", "MeshInstance3D")
	if meshes.size() == 0:
		printerr("LevelBounds: No meshes found in level root.")
		return
	
	var aabb: AABB = AABB()
	aabb.size = Vector3(1, 1, 1)
	aabb = global_transform * aabb

	for mesh: MeshInstance3D in meshes:
		var other: AABB = mesh.global_transform * mesh.get_aabb()
		aabb = aabb.merge(other)

	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = aabb.size

	var collision_shapes = find_children("", "CollisionShape3D")
	var collision_shape: CollisionShape3D
	if collision_shapes.size() == 0:
		collision_shape = CollisionShape3D.new()
		add_child(collision_shape)
	else:
		collision_shape = collision_shapes[0] as CollisionShape3D

	collision_shape.shape = shape
	collision_shape.global_position = aabb.get_center()

	Signals.safe_connect(self, body_exited, _on_body_exited)

func _on_body_exited(body: Node) -> void:
	if is_instance_valid(body) and not body.is_queued_for_deletion() and body.is_inside_tree():
		#print("Body exited bounds: %s" % body.get_path())
		exited_bounds.emit(body)
