extends CharacterBody2D

@export var ignore_time_scale: bool = false
@onready var camera: Camera2D = %Camera2D
var speed = 300

func _ready() -> void:
	if is_multiplayer_authority():
		camera.make_current()
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		
	if Multiprocess.get_first_instance(self).is_multiprocess_instance() and get_multiplayer_authority() == MultiplayerPeer.TARGET_PEER_SERVER:
		queue_free()

func get_input():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * speed
	if ignore_time_scale:
		velocity /= Engine.time_scale

func _physics_process(delta):
	get_input()
	move_and_collide(velocity * delta)
