extends CharacterBody3D

@export var speed : float = 22
@export var jump_height : float = 2.4
@export var mouse_look_speed : float = 0.002
@onready var camera : Camera3D = get_node("Camera3D")
var jump_velocity_to_add : float = 0
var mouse_movement : Vector2 = Vector2.ZERO
var gravity : Vector3

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

func _input(event:InputEvent):
	if is_on_floor() and event.is_action_pressed("Jump"):
		jump_velocity_to_add = sqrt(2*jump_height*(-gravity.y))
	if event is InputEventMouseMotion:
		mouse_movement.x -= event.relative.x * mouse_look_speed
		mouse_movement.y -= event.relative.y * mouse_look_speed

func _physics_process(delta):
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	
	velocity = get_input()
	velocity += gravity * delta
	velocity += Vector3(0, jump_velocity_to_add, 0)
	jump_velocity_to_add = 0
	
	velocity = global_transform.basis * velocity
	
	move_and_slide()
	
	rotate_y(mouse_movement.x)
	mouse_movement.x = 0
	camera.rotate_x(mouse_movement.y)
	mouse_movement.y = 0
