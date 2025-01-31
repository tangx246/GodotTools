class_name LightChecker
extends Node

@export var root: Node

func _ready() -> void:
	var lights = root.find_children("", "Light3D", true, false)
	for light: Light3D in lights:
		if light is not DirectionalLight3D:
			assert(light.distance_fade_enabled, "Light %s of type %s must have distance fade enabled" % [light.get_path(), light])

			if light.light_bake_mode == Light3D.BAKE_STATIC:
				light.set_param(Light3D.PARAM_RANGE, 10)
				light.distance_fade_enabled = true
				light.distance_fade_begin = 5
				light.distance_fade_length = 5
				light.distance_fade_shadow = 5
