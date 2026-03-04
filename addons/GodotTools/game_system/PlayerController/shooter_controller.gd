class_name ShooterController
extends CharacterBody3D

@export var speed : float = 10
@export var jump_height : float = 2.4
@export var mouse_look_speed : float = 0.002
@export var joy_look_speed: float = 2

@export var stand_state_controller : StandState
@export var lean_controller : Lean

@onready var camera : Camera3D = find_child("Camera3D")
var jump_velocity_to_add : float = 0
var mouse_movement : Vector2 = Vector2.ZERO
## Normalized local-space input direction. x = strafe (neg left, pos right), y = fwd/bwd (neg forward, pos backward)
var input_direction: Vector2 = Vector2.ZERO

signal hit_floor(fall_speed: float, fall_height: float)
signal mouse_looked(x_angle: float, y_angle: float)

func get_input() -> Vector3:
	var input_dir = Input.get_vector("Strafe Left", "Strafe Right", "Move Forward", "Move Backward")
	input_direction = input_dir
	var velocity2 = (input_dir * speed)
	return Vector3(velocity2.x, velocity.y, velocity2.y)

var mouse_captured: bool = false
func _ready() -> void:
	if is_multiplayer_authority():
		process_mode = PROCESS_MODE_INHERIT
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
	else:
		process_mode = PROCESS_MODE_DISABLED
		camera.clear_current(true)

func _exit_tree():
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	await PhysicsSync.wait_for_physics_frame()
	if is_on_floor():
		if event.is_action_pressed("Jump") and stand_state_controller.stand_state == StandState.STAND_STATE.STAND:
			jump_velocity_to_add = sqrt(2*jump_height*(get_gravity().length()))
		if event.is_action_pressed("Jump") and stand_state_controller.stand_state != StandState.STAND_STATE.STAND:
			stand_state_controller.stand_state = StandState.STAND_STATE.STAND
		if event.is_action_pressed("Crouch"):
			if stand_state_controller.stand_state == StandState.STAND_STATE.CROUCH:
				stand_state_controller.stand_state = StandState.STAND_STATE.STAND
			else:
				stand_state_controller.stand_state = StandState.STAND_STATE.CROUCH
		if event.is_action_pressed("Prone"):
			stand_state_controller.stand_state = StandState.STAND_STATE.PRONE

	if event.is_action_pressed("Lean Left"):
		lean_controller.lean_state = Lean.LEAN_STATE.LEFT
	if event.is_action_pressed("Lean Right"):
		lean_controller.lean_state = Lean.LEAN_STATE.RIGHT
	if event.is_action_released("Lean Left") or event.is_action_released("Lean Right"):
		lean_controller.lean_state = Lean.LEAN_STATE.NONE

	if event.is_action_pressed("Sprint"):
		stand_state_controller.sprint(true)
	if event.is_action_released("Sprint"):
		stand_state_controller.sprint(false)

	if event is InputEventMouseMotion:
		mouse_movement.x -= event.relative.x * mouse_look_speed * PlayerPrefs.get_value(MouseLookSensitivity.MOUSE_LOOK_KEY, 1.0)
		mouse_movement.y -= event.relative.y * mouse_look_speed * PlayerPrefs.get_value(MouseLookSensitivity.MOUSE_LOOK_KEY, 1.0)

## Accumulates joystick look input into mouse_movement. Call at the start of _process().
func _accumulate_joy_look(delta: float) -> void:
	var look_input = Input.get_vector("Look Left", "Look Right", "Look Down", "Look Up")
	mouse_movement.x -= look_input.x * delta * joy_look_speed
	mouse_movement.y += look_input.y * delta * joy_look_speed

## Resets mouse_movement after applying it. Call at the end of _process().
func _reset_mouse_movement() -> void:
	mouse_movement.x = 0
	mouse_movement.y = 0

## Applies gravity and jump to velocity. Returns the gravity direction vector.
func _apply_gravity_and_jump(delta: float) -> Vector3:
	velocity += get_gravity() * delta
	var gravity_direction: Vector3 = get_gravity().normalized()
	velocity -= gravity_direction * jump_velocity_to_add
	jump_velocity_to_add = 0
	return gravity_direction

## Calls move_and_slide() and emits hit_floor if landing was detected.
func _move_and_detect_landing(gravity_direction: Vector3) -> void:
	var previously_in_air: bool = not is_on_floor()
	var prev_velocity: Vector3 = velocity
	move_and_slide()

	if previously_in_air and is_on_floor():
		var fall_speed: float = prev_velocity.dot(gravity_direction)
		hit_floor.emit(fall_speed, (fall_speed * fall_speed) / (2 * get_gravity().length()))
