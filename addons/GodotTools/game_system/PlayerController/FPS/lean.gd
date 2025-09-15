class_name Lean
extends TweenObjectTo

@export var stand_position : Node3D
@export var standing_lean_left_position : Node3D
@export var standing_lean_right_position : Node3D
@export var lean_transition_speed : float = 0.1
@export_flags_3d_physics var collision_mask: int = 1

@export var lean_state : LEAN_STATE = LEAN_STATE.NONE:
	set(value):
		lean_state = value
		
		if is_inside_tree():
			lean_state_changed.emit(lean_transition_speed)
			if lean_state == LEAN_STATE.LEFT:
				set_physics_process(true)
			elif lean_state == LEAN_STATE.RIGHT:
				set_physics_process(true)
			else:
				set_physics_process(false)
				_tween_lean_to(Vector3.ZERO, Vector3.ZERO, lean_transition_speed)
			
enum LEAN_STATE { NONE, LEFT, RIGHT }

signal lean_state_changed(transition_time: float)

var relative_lean_left_position : Vector3
var relative_lean_right_position : Vector3
var raycaster: RayCast3D

func _ready() -> void:
	set_physics_process(false)
	
	relative_lean_left_position = standing_lean_left_position.position - stand_position.position
	relative_lean_right_position = standing_lean_right_position.position - stand_position.position

	raycaster = RayCast3D.new()
	raycaster.enabled = false
	raycaster.collision_mask = collision_mask
	add_child(raycaster)

func _tween_lean_to(position: Vector3, rotation: Vector3, time: float) -> Signal:
	return tween_object_to(self, position, rotation, time)

func _physics_process(_delta: float) -> void:
	var target_rotation: Vector3
	raycaster.global_position = get_parent().global_position
	if lean_state == LEAN_STATE.LEFT:
		raycaster.target_position = relative_lean_left_position
		target_rotation = standing_lean_left_position.rotation
	elif lean_state == LEAN_STATE.RIGHT:
		raycaster.target_position = relative_lean_right_position
		target_rotation = standing_lean_right_position.rotation
	raycaster.force_raycast_update()
	if raycaster.is_colliding():
		var collision_point: Vector3 = raycaster.get_collision_point()
		if global_position != collision_point:
			# Scale target rotation based on how far the collision point is
			target_rotation = target_rotation * (collision_point - global_position).length() / raycaster.target_position.length()
			_tween_lean_to(to_local(collision_point), target_rotation, lean_transition_speed)
	else:
		if global_position != raycaster.target_position:
			_tween_lean_to(raycaster.target_position, target_rotation, lean_transition_speed)
