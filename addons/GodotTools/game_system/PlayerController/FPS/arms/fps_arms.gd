extends Node3D

@export_flags_3d_render var fps_arms_layer : int
@export var fov: float = 75:
	set(value):
		fov = value
		set_renderers()
@export var shader_material: ShaderMaterial

func _ready() -> void:
	for child: Node in find_children("", "Node", true, false):
		child.child_order_changed.connect(set_renderers)

	set_renderers()

func set_renderers():
	var renderers = find_children("", "VisualInstance3D", true, false)
	for renderer: VisualInstance3D in renderers:
		var mesh := renderer as MeshInstance3D
		if mesh:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			replace_materials(mesh)
		renderer.layers = fps_arms_layer if is_multiplayer_authority() else 0
		
func replace_materials(mesh: MeshInstance3D) -> void:
	for i: int in range(mesh.get_surface_override_material_count()):
		var material: Material = mesh.get_active_material(i)
		if material is ShaderMaterial:
			material.set_shader_parameter("viewmodel_fov", fov)
			continue
		elif material is BaseMaterial3D:
			var new_material: ShaderMaterial = shader_material.duplicate(true)
			new_material.set_shader_parameter("viewmodel_fov", fov)
			new_material.set_shader_parameter("albedo", material.albedo_color)
			new_material.set_shader_parameter("point_size", material.point_size)
			new_material.set_shader_parameter("roughness", material.roughness)
			var texture_channel: Vector4
			if material.metallic_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_RED:
				texture_channel = Vector4(1, 0, 0, 0)
			elif material.metallic_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_GREEN:
				texture_channel = Vector4(0, 1, 0, 0)
			elif material.metallic_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_BLUE:
				texture_channel = Vector4(0, 0, 1, 0)
			elif material.metallic_texture_channel == BaseMaterial3D.TEXTURE_CHANNEL_ALPHA:
				texture_channel = Vector4(0, 0, 0, 1)
			else:
				texture_channel = Vector4(0, 0, 0, 0)
			new_material.set_shader_parameter("material_texture_channel", texture_channel)
			new_material.set_shader_parameter("specular", material.metallic_specular)
			new_material.set_shader_parameter("metallic", material.metallic)
			new_material.set_shader_parameter("normal_scale", material.normal_scale)
			new_material.set_shader_parameter("rim", material.rim)
			new_material.set_shader_parameter("rim_tint", material.rim_tint)
			new_material.set_shader_parameter("uv1_scale", material.uv1_scale)
			new_material.set_shader_parameter("uv1_offset", material.uv1_offset)
			new_material.set_shader_parameter("uv2_scale", material.uv2_scale)
			new_material.set_shader_parameter("uv2_offset", material.uv2_offset)
			new_material.set_shader_parameter("texture_albedo", material.albedo_texture)
			new_material.set_shader_parameter("texture_metallic", material.metallic_texture)
			new_material.set_shader_parameter("texture_roughness", material.roughness_texture)
			new_material.set_shader_parameter("texture_normal", material.normal_texture)
			new_material.set_shader_parameter("texture_rim", material.rim_texture)
			mesh.set_surface_override_material(i, new_material)
		else:
			printerr("Unable to handle material %s" % material)
