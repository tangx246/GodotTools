class_name TweenObjectTo
extends Node3D

var transitions : Dictionary
func tween_object_to(object: Object, position: Vector3, rotation: Vector3, time: float) -> Signal:
	var key = object.to_string()
	var current_transition = transitions.get(key)
	if current_transition:
		current_transition.kill()
		transitions.erase(key)
		
	current_transition = create_tween()
	current_transition.set_parallel()
	current_transition.tween_property(object, "position", position, time)
	current_transition.tween_property(object, "rotation", rotation, time)
	current_transition.set_parallel(false)
	transitions[key] = current_transition
	current_transition.tween_callback(func(): transitions.erase(key))
	return current_transition.finished
