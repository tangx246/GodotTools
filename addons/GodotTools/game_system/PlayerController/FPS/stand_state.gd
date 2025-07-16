class_name StandState
extends TweenObjectTo

@export var body: Node3D
@export var speed_var: StringName = "speed"

@export_group("Stand")
@export var stand_collider: CollisionShape3D
@export var crouch_collider: CollisionShape3D
@export var prone_collider: CollisionShape3D
@export var walk_speed: float = 1
@export var stand_speed: float = 10
@export var sprint_speed: float = 22
@export var stand_position: Node3D
@export var stand_transition_speed: float = 0.2

@export_group("Crouch")
@export var crouch_position: Node3D
@export var crouch_speed: float = 3.6
@export var crouch_transition_speed: float = 0.2

@export_group("Prone")
@export var prone_position: Node3D
@export var prone_speed: float = 1
@export var prone_transition_speed: float = 0.4

@export var stand_state: STAND_STATE = STAND_STATE.STAND:
	set(value):
		var prev_value = stand_state
		stand_state = value
		
		if is_inside_tree():
			_set_collider()
			_transition_stand_state(prev_value, value)
enum STAND_STATE {STAND, CROUCH, PRONE}

signal stand_state_changed(transition_time: float)

func _set_collider():
	var colliders: Array[CollisionShape3D] = [stand_collider, crouch_collider, prone_collider]
	for i in range(colliders.size()):
		colliders[i].disabled = i != stand_state

func _ready() -> void:
	_set_collider()
	body.set(speed_var, stand_speed)

func _transition_stand_state(prevValue: STAND_STATE, value: STAND_STATE):
	if prevValue == value:
		return
	
	if prevValue == STAND_STATE.STAND:
		if value == STAND_STATE.CROUCH:
			body.set(speed_var, crouch_speed)
			stand_state_changed.emit(crouch_transition_speed)
			_tween_camera_root_to(crouch_position.position, crouch_transition_speed)
		elif value == STAND_STATE.PRONE:
			body.set(speed_var, prone_speed)
			stand_state_changed.emit(crouch_transition_speed + prone_transition_speed)
			_tween_camera_root_to(prone_position.position, crouch_transition_speed + prone_transition_speed)
	elif prevValue == STAND_STATE.CROUCH:
		if value == STAND_STATE.STAND:
			stand_state_changed.emit(stand_transition_speed)
			await _tween_camera_root_to(stand_position.position, stand_transition_speed)
			body.set(speed_var, stand_speed)
		elif value == STAND_STATE.PRONE:
			body.set(speed_var, prone_speed)
			stand_state_changed.emit(prone_transition_speed)
			_tween_camera_root_to(prone_position.position, prone_transition_speed)
	elif prevValue == STAND_STATE.PRONE:
		if value == STAND_STATE.STAND:
			stand_state_changed.emit(crouch_transition_speed + stand_transition_speed)
			await _tween_camera_root_to(stand_position.position, crouch_transition_speed + stand_transition_speed)
			body.set(speed_var, stand_speed)
		elif value == STAND_STATE.CROUCH:
			stand_state_changed.emit(crouch_transition_speed)
			await _tween_camera_root_to(crouch_position.position, crouch_transition_speed)
			body.set(speed_var, crouch_speed)

func refresh_speed() -> void:
	if stand_state == STAND_STATE.STAND:
		body.set(speed_var, stand_speed)
	elif stand_state == STAND_STATE.CROUCH:
		body.set(speed_var, crouch_speed)
	elif stand_state == STAND_STATE.PRONE:
		body.set(speed_var, prone_speed)

func walk(walking: bool):
	if stand_state == STAND_STATE.STAND:
		if walking:
			body.set(speed_var, walk_speed)
		else:
			body.set(speed_var, stand_speed)

func sprint(sprinting: bool):
	if sprinting and stand_state == STAND_STATE.STAND:
		await _wait_cameraRoot_tweens()
		body.set(speed_var, sprint_speed)
	if sprinting and stand_state != STAND_STATE.STAND:
		stand_state = STAND_STATE.STAND
		await _wait_cameraRoot_tweens()
		body.set(speed_var, sprint_speed)
	if not sprinting and stand_state == STAND_STATE.STAND:
		await _wait_cameraRoot_tweens()
		body.set(speed_var, stand_speed)

func _tween_camera_root_to(position: Vector3, time: float) -> Signal:
	return tween_object_to(self, position, Vector3.ZERO, time)

func _wait_cameraRoot_tweens() -> void:
	var transition: Tween = transitions.get(self.to_string()) as Tween
	if transition:
		await transition.finished
