## Not actually just a light checker. Checks for various errors and performance gotchas in the scene
class_name LightChecker
extends Node

@export var root: Node
@export var min_texel_scale: float = 1
@export var disable_negative_scale_check: bool = false
@export var print_lights_count: bool = false

func _ready() -> void:
	var lights = root.find_children("", "Light3D", true, false)
	_light_settings(lights)		
	
	# Everything past here are static checks that shouldn't run in a regular build
	if not OS.has_feature("editor"):
		return
	
	_light_count(lights)
	_rigidbody_check()
	_lightmap_check()
	#_check_jolt_scaling() # Not a reliable way of detecting Jolt scaling error
	if not disable_negative_scale_check:
		_check_negative_scales()

## Set sane performance parameters for lights
func _light_settings(lights: Array) -> void:
	for light: Light3D in lights:
		if light is not DirectionalLight3D:
			if light.light_bake_mode == Light3D.BAKE_STATIC:
				if light.get_param(Light3D.PARAM_RANGE) > 10:
					light.set_param(Light3D.PARAM_RANGE, 10)
				light.distance_fade_enabled = true
				light.distance_fade_begin = minf(15, light.distance_fade_begin)
				light.distance_fade_length = minf(10, light.distance_fade_length)
				light.distance_fade_shadow = minf(0, light.distance_fade_shadow)
			else:
				light.distance_fade_begin = minf(15, light.distance_fade_begin)
				light.distance_fade_length = minf(10, light.distance_fade_length)
				light.distance_fade_shadow = minf(15, light.distance_fade_shadow)

func _light_count(lights: Array) -> void:
	var static_lights: int = 0
	var dynamic_lights: int = 0
	var directional_lights: int = 0
	
	for light: Light3D in lights:
		if light is not DirectionalLight3D:
			assert(light.distance_fade_enabled, "Light %s of type %s must have distance fade enabled" % [light.get_path(), light])
				
			if light.light_bake_mode == Light3D.BAKE_STATIC:
				static_lights += 1
			else:
				dynamic_lights += 1
		else:
			directional_lights += 1
	
	if print_lights_count:
		print("%s static lights, %s dynamic lights, %s directional lights" % [static_lights, dynamic_lights, directional_lights])

func _rigidbody_check() -> void:
	var rigidbodies = root.find_children("", "RigidBody3D", true, false)
	for rigidbody: RigidBody3D in rigidbodies:
		var geometries = rigidbody.find_children("", "GeometryInstance3D", true, false)
		for geometry: GeometryInstance3D in geometries:
			assert(
				geometry.gi_mode != GeometryInstance3D.GIMode.GI_MODE_STATIC, 
				"GeometryInstance3D %s is part of a RigidBody3D and should not contribute to global illumination (i.e. Global Illumination Mode should not be static)" % geometry.get_path())

func _lightmap_check() -> void:
	var lightmapgis = root.find_children("", "LightmapGI", true, false)
	for lmgi: LightmapGI in lightmapgis:
		assert(lmgi.texel_scale >= min_texel_scale,
		"Texel Scale must equal %s" % min_texel_scale)

func _check_jolt_scaling() -> void:
	var physicsbodies = root.find_children("", "PhysicsBody3D", true, false)
	for body: PhysicsBody3D in physicsbodies:
		var scale: Vector3 = body.global_basis.get_scale()
		if not (is_equal_approx(scale.x, scale.y) and is_equal_approx(scale.y, scale.z)):
			body.process_mode = Node.PROCESS_MODE_DISABLED
			printerr("PhysicsBody %s with scale %s should have uniform scale" % [body.get_path(), scale])

func _check_negative_scales() -> void:
	var nodes = root.find_children("", "Node3D", true, false)
	var negative_nodes: Array[String] = []
	for node: Node3D in nodes:
		var scale: Vector3 = node.global_basis.get_scale()
		if scale.x < 0 or scale.y < 0 or scale.z < 0:
			negative_nodes.append("%s [%s]" % [node.get_path(), scale])

	assert(
		negative_nodes.size() == 0,
		"Node3Ds %s has negative scale. This can cause issues with physics and rendering." % "\n".join(negative_nodes))
