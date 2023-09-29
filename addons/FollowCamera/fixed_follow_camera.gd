extends Camera3D
class_name FixedFollowCamera

@export var target : Node3D
@export var translation : Vector3 = Vector3(-3, 3, 0)

func _process(delta):
	position = target.position + translation
