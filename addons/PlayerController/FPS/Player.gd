class_name FPSController
extends CharacterBody3D

@export var speed : float = 10
@export var jump_height : float = 2.4
@export var mouse_look_speed : float = 0.002

@export_group("Stand")
@export var stand_speed : float = 10
@export var sprint_speed : float = 22
@export var stand_position : Node3D
@export var stand_transition_speed : float = 0.2
@export var standing_lean_left_position : Node3D
@export var standing_lean_right_position : Node3D
@export var lean_transition_speed : float = 0.1
@export var stand_collider : CollisionShape3D

@export_group("Crouch")
@export var crouch_position : Node3D
@export var crouch_speed : float = 3.6
@export var crouch_transition_speed : float = 0.2
@export var crouch_collider : CollisionShape3D

@export_group("Prone")
@export var prone_position : Node3D
@export var prone_speed : float = 1
@export var prone_transition_speed : float = 0.4
@export var prone_collider : CollisionShape3D

@export_group("Camera")
@export var cameraRoot : Node3D
@export var leanRoot : Node3D

@export_group("Multiplayer Synced Variables")
@export var stand_state : STAND_STATE = STAND_STATE.STAND:
	set(value):
		var prev_value = stand_state
		stand_state = value
		_set_collider()
		_transition_stand_state(prev_value, value)
enum STAND_STATE { STAND, CROUCH, PRONE }
@export var lean_state : LEAN_STATE = LEAN_STATE.NONE:
	set(value):
		lean_state = value
		lean_state_changed.emit(lean_transition_speed)
enum LEAN_STATE { NONE, LEFT, RIGHT }

@onready var camera : Camera3D = find_child("Camera3D")
var jump_velocity_to_add : float = 0
var mouse_movement : Vector2 = Vector2.ZERO
var gravity : Vector3
var relative_lean_left_position : Vector3
var relative_lean_right_position : Vector3

signal stand_state_changed(transition_time: float)
signal lean_state_changed(transition_time: float)

func _set_collider():
	var colliders : Array[CollisionShape3D] = [stand_collider, crouch_collider, prone_collider]
	for i in range(colliders.size()):
		colliders[i].disabled = i != stand_state

func get_input() -> Vector3:
	var input_dir = Input.get_vector("Strafe Left", "Strafe Right", "Move Forward", "Move Backward")
	var velocity2 = (input_dir * speed)
	return Vector3(velocity2.x, velocity.y, velocity2.y)

func _ready():	
	if is_multiplayer_authority():
		process_mode = PROCESS_MODE_INHERIT
		camera.make_current()
	else:
		process_mode = PROCESS_MODE_DISABLED
		camera.clear_current(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	relative_lean_left_position = standing_lean_left_position.position - stand_position.position
	relative_lean_right_position = standing_lean_right_position.position - stand_position.position
	
	_set_collider()

func _tween_camera_root_to(position: Vector3, time: float) -> Signal:
	return _tween_object_to(cameraRoot, position, Vector3.ZERO, time)

func _tween_lean_to(position: Vector3, rotation: Vector3, time: float) -> Signal:
	return _tween_object_to(leanRoot, position, rotation, time)

var transitions : Dictionary
func _tween_object_to(object: Object, position: Vector3, rotation: Vector3, time: float) -> Signal:
	var current_transition = transitions.get(object.to_string())
	if current_transition:
		current_transition.kill()
		transitions.erase(object.to_string())
		
	current_transition = create_tween()
	current_transition.set_parallel()
	current_transition.tween_property(object, "position", position, time)
	current_transition.tween_property(object, "rotation", rotation, time)
	transitions[object.to_string()] = current_transition
	current_transition.tween_callback(func(): transitions.erase(object.to_string()))
	return current_transition.finished

func _transition_stand_state(prevValue: STAND_STATE, value: STAND_STATE):
	if prevValue == value:
		return
	
	if prevValue == STAND_STATE.STAND:
		if value == STAND_STATE.CROUCH:
			speed = crouch_speed
			stand_state_changed.emit(crouch_transition_speed)
			_tween_camera_root_to(crouch_position.position, crouch_transition_speed)
		elif value == STAND_STATE.PRONE:
			speed = prone_speed
			stand_state_changed.emit(crouch_transition_speed + prone_transition_speed)
			_tween_camera_root_to(prone_position.position, crouch_transition_speed + prone_transition_speed)
	elif prevValue == STAND_STATE.CROUCH:
		if value == STAND_STATE.STAND:
			stand_state_changed.emit(stand_transition_speed)
			await _tween_camera_root_to(stand_position.position, stand_transition_speed)
			speed = stand_speed
		elif value == STAND_STATE.PRONE:
			speed = prone_speed
			stand_state_changed.emit(prone_transition_speed)
			_tween_camera_root_to(prone_position.position, prone_transition_speed)
	elif prevValue == STAND_STATE.PRONE:
		if value == STAND_STATE.STAND:
			stand_state_changed.emit(crouch_transition_speed + stand_transition_speed)
			await _tween_camera_root_to(stand_position.position, crouch_transition_speed + stand_transition_speed)
			speed = stand_speed
		elif value == STAND_STATE.CROUCH:
			stand_state_changed.emit(crouch_transition_speed)
			await _tween_camera_root_to(crouch_position.position, crouch_transition_speed)
			speed = crouch_speed

func _input(event:InputEvent):
	if is_on_floor():
		if event.is_action_pressed("Jump") and stand_state == STAND_STATE.STAND:
			jump_velocity_to_add = sqrt(2*jump_height*(-gravity.y))
		if event.is_action_pressed("Jump") and stand_state != STAND_STATE.STAND:
			stand_state = STAND_STATE.STAND
		if event.is_action_pressed("Crouch"):
			if stand_state == STAND_STATE.CROUCH:
				stand_state = STAND_STATE.STAND
			else:
				stand_state = STAND_STATE.CROUCH
		if event.is_action_pressed("Prone"):
			stand_state = STAND_STATE.PRONE
		if event.is_action_pressed("Lean Left"):
			_tween_lean_to(relative_lean_left_position, standing_lean_left_position.rotation, lean_transition_speed)
			lean_state = LEAN_STATE.LEFT
		if event.is_action_pressed("Lean Right"):
			_tween_lean_to(relative_lean_right_position, standing_lean_right_position.rotation, lean_transition_speed)
			lean_state = LEAN_STATE.RIGHT
		if event.is_action_released("Lean Left") or event.is_action_released("Lean Right"):
			_tween_lean_to(Vector3.ZERO, Vector3.ZERO, lean_transition_speed)
			lean_state = LEAN_STATE.NONE
			
	if event.is_action_pressed("Sprint") and stand_state == STAND_STATE.STAND:
		await _wait_cameraRoot_tweens()
		speed = sprint_speed
	if event.is_action_pressed("Sprint") and stand_state != STAND_STATE.STAND:
		stand_state = STAND_STATE.STAND
		await _wait_cameraRoot_tweens()
		speed = sprint_speed
	if event.is_action_released("Sprint"):
		await _wait_cameraRoot_tweens()
		speed = stand_speed
	
	if event is InputEventMouseMotion:
		mouse_movement.x -= event.relative.x * mouse_look_speed
		mouse_movement.y -= event.relative.y * mouse_look_speed

func _wait_cameraRoot_tweens() -> void:
	var transition : Tween = transitions.get(cameraRoot.to_string()) as Tween
	if transition:
		await transition.finished

func _process(_delta: float) -> void:
	rotate_y(mouse_movement.x)
	mouse_movement.x = 0
	camera.rotate_x(mouse_movement.y)
	camera.rotation.x = clampf(camera.rotation.x, -PI/2, PI/2)
	mouse_movement.y = 0

func _physics_process(delta):
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	
	velocity = get_input()
	velocity += gravity * delta
	velocity += Vector3(0, jump_velocity_to_add, 0)
	jump_velocity_to_add = 0
	
	velocity = global_transform.basis * velocity
	
	move_and_slide()
