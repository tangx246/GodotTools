@tool
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

var editor_wait_time: float = 0
func _ready() -> void:
	mixers = []
	mixers.assign(root.find_children("", "AnimationMixer"))
	
	if Engine.is_editor_hint():
		Signals.safe_connect(self, get_tree().process_frame, func():
			editor_wait_time += get_process_delta_time()
			if editor_wait_time >= wait_time:
				for mixer in mixers:
					mixer.advance(editor_wait_time)
					
				editor_wait_time = 0
		)

	stop()
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = randf_range(0, 1)
	add_child(timer)

	await timer.timeout

	timer.wait_time = distance_update_tick
	timer.one_shot = false
	Signals.safe_connect(self, timer.timeout, _distance_update)
	timer.start()
	_distance_update()

	start()
	Signals.safe_connect(self, timeout, _on_tick, CONNECT_DEFERRED)

func _on_tick():
	for mixer in mixers:
		mixer.advance.call_deferred(wait_time)

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
