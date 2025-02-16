class_name LightChecker
extends Node

@export var root: Node

func _ready() -> void:
	var static_lights: int = 0
	var dynamic_lights: int = 0
	var directional_lights: int = 0
	
	var lights = root.find_children("", "Light3D", true, false)
	for light: Light3D in lights:
		if light is not DirectionalLight3D:
			assert(light.distance_fade_enabled, "Light %s of type %s must have distance fade enabled" % [light.get_path(), light])

			if light.light_bake_mode == Light3D.BAKE_STATIC:
				if light.get_param(Light3D.PARAM_RANGE) > 10:
					light.set_param(Light3D.PARAM_RANGE, 10)
				light.distance_fade_enabled = true
				light.distance_fade_begin = 5
				light.distance_fade_length = 5
				light.distance_fade_shadow = 0
				
				if light is OmniLight3D:
					light.omni_shadow_mode = OmniLight3D.SHADOW_DUAL_PARABOLOID
				
				static_lights += 1
			else:
				dynamic_lights += 1
		else:
			# Static directional lights
			if light.light_bake_mode == Light3D.BAKE_STATIC:
				var directionalLight := light as DirectionalLight3D
				directionalLight.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
			
			directional_lights += 1
				
	print("%s static lights, %s dynamic lights, %s directional lights" % [static_lights, dynamic_lights, directional_lights])
