class_name ShaderMaterialColorSetter extends Node3D

@export var parent : NodePath
@export var surface_input_name : String

func set_color(color : Color):
	var meshes = get_node(parent).find_children("", "MeshInstance3D", true, false)
	for mesh : MeshInstance3D in meshes:
		for i in range(0, mesh.mesh.get_surface_count()):
			var material = mesh.get_active_material(i)
			if material is ShaderMaterial:
				if material.get_shader_parameter(surface_input_name) != null:
					var shaderMaterial = material.duplicate() as ShaderMaterial
					shaderMaterial.set_shader_parameter(surface_input_name, color)
					mesh.set_surface_override_material(i, shaderMaterial)
