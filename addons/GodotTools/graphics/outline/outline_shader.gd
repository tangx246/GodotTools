@tool
extends Node


func _ready() -> void:
	var method: String = ProjectSettings.get_setting("rendering/renderer/rendering_method", "forward_plus")
	if method == "gl_compatibility":
		for child in get_children():
			if child is Node3D:
				child.visible = false
