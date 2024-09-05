extends CharacterBody3D

@export var speed : float = 22
@export var jump_height : float = 2.4
@export var mouse_look_speed : float = 0.002

@export_group("Stand")
@export var stand_speed : float = 22
@export var stand_position : Node3D
@export var stand_transition_speed : float = 0.2

@export_group("Crouch")
@export var crouch_position : Node3D
@export var crouch_speed : float = 3.6
@export var crouch_transition_speed : float = 0.2

@export_group("Prone")
@export var prone_position : Node3D
@export var prone_speed : float = 1
@export var prone_transition_speed : float = 0.4

@export_group("Multiplayer Authority")
@export_flags_3d_physics var authority_layer : int = 1
@export_flags_3d_physics var no_authority_layer : int = 1

@export_group("Multiplayer Synced Variables")
@export var stand_state : STAND_STATE = STAND_STATE.STAND:
	get:
		return stand_state
	set(value):
		var prev_value = stand_state
		stand_state = value
		_transition_stand_state(prev_value, value)
		stand_state_changed.emit()

enum STAND_STATE { STAND, CROUCH, PRONE }

@onready var camera : Camera3D = find_child("Camera3D")
var jump_velocity_to_add : float = 0
var mouse_movement : Vector2 = Vector2.ZERO
var gravity : Vector3

signal stand_state_changed

func get_input() -> Vector3:
	var input_dir = Input.get_vector("Strafe Left", "Strafe Right", "Move Forward", "Move Backward")
	var velocity2 = (input_dir * speed)
	return Vector3(velocity2.x, velocity.y, velocity2.y)

func _ready():	
	if is_multiplayer_authority():
		process_mode = PROCESS_MODE_INHERIT
		camera.make_current()
		collision_layer = authority_layer
	else:
		process_mode = PROCESS_MODE_DISABLED
		camera.clear_current(true)
		collision_layer = no_authority_layer
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var current_transition : Tween
func _tween_camera_to(position: Vector3, time: float) -> Signal:
	if current_transition:
		current_transition.kill()
		current_transition = null
		
	current_transition = create_tween()
	current_transition.tween_property(camera.get_parent(), "position", position, time)
	return current_transition.finished

func _transition_stand_state(prevValue: STAND_STATE, value: STAND_STATE):
	if prevValue == value:
		return
	
	if prevValue == STAND_STATE.STAND:
		if value == STAND_STATE.CROUCH:
			speed = crouch_speed
			_tween_camera_to(crouch_position.position, crouch_transition_speed)
		elif value == STAND_STATE.PRONE:
			speed = prone_speed
			_tween_camera_to(prone_position.position, crouch_transition_speed + prone_transition_speed)
	elif prevValue == STAND_STATE.CROUCH:
		if value == STAND_STATE.STAND:
			await _tween_camera_to(stand_position.position, stand_transition_speed)
			speed = stand_speed
		elif value == STAND_STATE.PRONE:
			speed = prone_speed
			_tween_camera_to(prone_position.position, prone_transition_speed)
	elif prevValue == STAND_STATE.PRONE:
		if value == STAND_STATE.STAND:
			await _tween_camera_to(stand_position.position, crouch_transition_speed + stand_transition_speed)
			speed = stand_speed
		elif value == STAND_STATE.CROUCH:
			await _tween_camera_to(crouch_position.position, crouch_transition_speed)
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
	
	if event is InputEventMouseMotion:
		mouse_movement.x -= event.relative.x * mouse_look_speed
		mouse_movement.y -= event.relative.y * mouse_look_speed

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
