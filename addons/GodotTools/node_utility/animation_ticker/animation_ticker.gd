class_name AnimationTicker
extends Timer

@export var root: Node3D
## How often to check camera distance
@export var distance_update_tick: float = 1
## Distance to start reducing tick rate
@export var long_distance: float = 50
## How often to tick at long distance from the camera
@export var long_distance_wait_time: float = 10
var mixers: Array[AnimationMixer]
var original_wait_time: float

func _init() -> void:
	original_wait_time = wait_time

func _ready() -> void:
	mixers = []
	mixers.assign(root.find_children("", "AnimationMixer"))

	stop()
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = randf_range(0, 1)
	add_child(timer)

	await timer.timeout

	timer.wait_time = distance_update_tick
	timer.one_shot = false
	timer.timeout.connect(_distance_update)
	timer.start()
	_distance_update()

	start()
	timeout.connect(_on_tick)

func _on_tick():
	for mixer in mixers:
		mixer.advance(wait_time)

func _distance_update():
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return

	var to_set: float
	if camera.global_position.distance_to(root.global_position) > long_distance:
		to_set = long_distance_wait_time
	else:
		to_set = original_wait_time

	if to_set != wait_time:
		wait_time = to_set
		start()
