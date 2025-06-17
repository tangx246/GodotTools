@tool
class_name FollowTarget
extends Node3D

@export var target: Node3D
@export var localOffset: Vector3
## Distance away from the camera where the number of ticks is reduced
@export var reduce_tick_camera_distance: float = 30
## Number of frames to tick at when past the reduced tick distance threshold
@export var reduced_tick_frames: int = 1000
## Number of frames to tick at when close to the camera
@export var short_distance_tick_frames: int = 3
@export var camera_distance_tick_rate: int = 100

@export_group("Editor Only")
@export var track_target_in_editor: bool = false:
	set(value):
		track_target_in_editor = value
		
		if Engine.is_editor_hint():
			set_physics_process(track_target_in_editor)
				
var tick_variance: int
var reduce_tick_camera_distance_squared: float
var track_target_callable: Callable
var camera: Camera3D
func _ready() -> void:
	reduce_tick_camera_distance_squared = reduce_tick_camera_distance * reduce_tick_camera_distance
	tick_variance = randi() % 10000

	if Engine.is_editor_hint():
		track_target_callable = track_target_editor
		set_physics_process(track_target_in_editor)
	elif localOffset == Vector3.ZERO:
		track_target_callable = track_target_no_translate
	else:
		track_target_callable = track_target

var short_distance: bool = true
func _physics_process(_delta: float) -> void:
	if not camera:
		camera = get_viewport().get_camera_3d()
		
		if not camera:
			return
	
	var ticks: int = Engine.get_physics_frames() + tick_variance
	if ticks % camera_distance_tick_rate == 0:
		var new_short_distance: bool = camera.global_position.distance_squared_to(global_position) < reduce_tick_camera_distance_squared
		
		if short_distance != new_short_distance:
			short_distance = new_short_distance
	
	if short_distance and ticks % short_distance_tick_frames == 0:
		track_target_callable.call()
	elif ticks % reduced_tick_frames == 0:
		track_target_callable.call()

func track_target() -> void:
	_calculate_offset(target.global_transform, localOffset)

func track_target_editor() -> void:
	_calculate_offset.bind(target.global_transform, localOffset).call()

func _calculate_offset(target_transform: Transform3D, offset: Vector3) -> void:
	_set_transform(target_transform.translated_local(offset))
	
func _set_transform(target_transform: Transform3D) -> void:
	global_transform = target_transform

func track_target_no_translate() -> void:
	global_transform = target.global_transform
