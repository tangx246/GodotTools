extends CharacterBody3D


@export var gravity : Vector3 = Vector3(0, -9.81, 0)
@export var speed : float = 22
@export var jump_height : float = 2.4
var jump_velocity_to_add : float = 0

func get_input() -> Vector3:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var velocity2 = (input_dir * speed)
	return Vector3(-velocity2.x, velocity.y, -velocity2.y)

func _ready():
	pass

func _input(event:InputEvent):
	if is_on_floor() and event.is_action_pressed("Jump"):
		jump_velocity_to_add = sqrt(2*jump_height*(-gravity.y))

func _process(delta):
	velocity = get_input()
	velocity += gravity * delta
	velocity += Vector3(0, jump_velocity_to_add, 0)
	jump_velocity_to_add = 0
	
	move_and_slide()
