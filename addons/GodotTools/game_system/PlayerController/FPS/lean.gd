class_name Lean
extends TweenObjectTo

@export var stand_position : Node3D
@export var standing_lean_left_position : Node3D
@export var standing_lean_right_position : Node3D
@export var lean_transition_speed : float = 0.1

@export var lean_state : LEAN_STATE = LEAN_STATE.NONE:
	set(value):
		lean_state = value
		
		if is_inside_tree():
			lean_state_changed.emit(lean_transition_speed)
			if lean_state == LEAN_STATE.LEFT:
				_tween_lean_to(relative_lean_left_position, standing_lean_left_position.rotation, lean_transition_speed)
			elif lean_state == LEAN_STATE.RIGHT:
				_tween_lean_to(relative_lean_right_position, standing_lean_right_position.rotation, lean_transition_speed)
			else:
				_tween_lean_to(Vector3.ZERO, Vector3.ZERO, lean_transition_speed)
			
enum LEAN_STATE { NONE, LEFT, RIGHT }

signal lean_state_changed(transition_time: float)

var relative_lean_left_position : Vector3
var relative_lean_right_position : Vector3

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return

	relative_lean_left_position = standing_lean_left_position.position - stand_position.position
	relative_lean_right_position = standing_lean_right_position.position - stand_position.position

func _tween_lean_to(position: Vector3, rotation: Vector3, time: float) -> Signal:
	return tween_object_to(self, position, rotation, time)
