class_name LightChecker
extends Node

@export var root: Node

func _ready() -> void:	
	var lights = root.find_children("", "Light3D", true, false)
	for light: Light3D in lights:
		if light is not DirectionalLight3D:
			if light.light_bake_mode == Light3D.BAKE_STATIC:
				if light.get_param(Light3D.PARAM_RANGE) > 10:
					light.set_param(Light3D.PARAM_RANGE, 10)
				light.distance_fade_enabled = true
				light.distance_fade_begin = 15
				light.distance_fade_length = 10
				light.distance_fade_shadow = 0
	
	# Everything past here are static checks that shouldn't run in a regular build
	if not OS.has_feature("editor"):
		return
	
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
			
	print("%s static lights, %s dynamic lights, %s directional lights" % [static_lights, dynamic_lights, directional_lights])
	
	var rigidbodies = root.find_children("", "RigidBody3D", true, false)
	for rigidbody: RigidBody3D in rigidbodies:
		var geometries = rigidbody.find_children("", "GeometryInstance3D", true, false)
		for geometry: GeometryInstance3D in geometries:
			assert(
				geometry.gi_mode != GeometryInstance3D.GIMode.GI_MODE_STATIC, 
				"GeometryInstance3D %s is part of a RigidBody3D and should not contribute to global illumination (i.e. Global Illumination Mode should not be static)" % geometry.get_path())
