class_name AnimationTicker
extends Timer

@export var root: Node3D
## How often to check camera distance. Randomizes between lower_bound and upper_bound
@export var distance_update_tick_lower_bound: float = 1
## How often to check camera distance. Randomizes between lower_bound and upper_bound
@export var distance_update_tick_upper_bound: float = 2
## Distance to start reducing tick rate
@export var long_distance: float = 15
## How often to tick at long distance from the camera. Randomizes between lower_bound and upper_bound
@export var long_distance_wait_time_lower_bound: float = 10
@export var long_distance_wait_time_upper_bound: float = 20
@export var update_mode: UPDATE_MODE = UPDATE_MODE.PROCESS
var mixers: Array[AnimationMixer]
var skeletons: Array[Skeleton3D]
var original_wait_time: float
var visibility_notifier: VisibleOnScreenNotifier3D

enum UPDATE_MODE {
	PROCESS,
	WAIT_TIME
}

func _init() -> void:
	original_wait_time = wait_time

var editor_wait_time: float = 0
func _ready() -> void:
	assert(process_mode == PROCESS_MODE_PAUSABLE, "Process mode for AnimationTicker must be Pausable")

	visibility_notifier = VisibleOnScreenNotifier3D.new()
	Signals.safe_connect(self, visibility_notifier.screen_entered, func(): _distance_update)
	Signals.safe_connect(self, visibility_notifier.screen_exited, func(): _distance_update)
	root.add_child.call_deferred(visibility_notifier)

	mixers = []
	mixers.assign(root.find_children("", "AnimationMixer"))
	var anim_players_to_remove: Array[AnimationPlayer] = []
	for mixer: AnimationMixer in mixers:
		mixer.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		
		if mixer is AnimationTree:
			var anim_player = mixer.get_node(mixer.anim_player)
			if mixers.has(anim_player):
				anim_players_to_remove.append(anim_player)

	for anim_player: AnimationPlayer in anim_players_to_remove:
		mixers.erase(anim_player)

	skeletons = []
	_refresh_skeletons()

	_distance_update()

	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = randf_range(distance_update_tick_lower_bound, distance_update_tick_upper_bound)
	add_child(timer)

	Signals.safe_connect(self, timer.timeout, _distance_update)
	timer.start()

	Signals.safe_connect(self, timeout, func():
		_on_tick(wait_time))

func _refresh_skeletons() -> void:
	skeletons.assign(root.find_children("", "Skeleton3D"))
	for skeleton: Skeleton3D in skeletons:
		skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_MANUAL

func _process(delta: float) -> void:
	_on_tick(delta)

func _on_tick(delta: float):
	for mixer in mixers:
		mixer.advance.call_deferred(delta)

	var needs_refresh: bool = false
	for skeleton: Skeleton3D in skeletons:
		if skeleton:
			skeleton.advance.call_deferred(delta)
		else:
			needs_refresh = true

	if needs_refresh:
		_refresh_skeletons()

func _distance_update():
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return

	var to_set: float
	if camera.global_position.distance_to(root.global_position) < long_distance or visibility_notifier.is_on_screen():
		if update_mode == UPDATE_MODE.WAIT_TIME:
			to_set = original_wait_time
		elif update_mode == UPDATE_MODE.PROCESS:
			to_set = -1
		else:
			push_error("Unhandled update mode %s" % update_mode)
	else:
		to_set = randf_range(long_distance_wait_time_lower_bound, long_distance_wait_time_upper_bound)
	
	if to_set < 0:
		set_process(true)
		stop()
	else:
		if wait_time != to_set:
			wait_time = to_set
		if is_stopped(): 
			start()
		set_process(false)
