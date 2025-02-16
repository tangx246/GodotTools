@tool
class_name FollowTarget
extends Node3D

@export var target: Node3D
@export var localOffset: Vector3
## Distance away from the camera where the number of ticks is reduced
@export var reduce_tick_camera_distance: float = 30
## Number of frames to tick at when past the reduced tick distance threshold
@export var reduced_tick_frames: int = 1000
@export var camera_distance_tick_rate: int = 100

@export_group("Editor Only")
@export var track_target_in_editor: bool = false

var distance_check_ticks: int = 0
var idle_ticks: int = 0
var reduce_tick_camera_distance_squared: float
func _ready() -> void:
	reduce_tick_camera_distance_squared = reduce_tick_camera_distance * reduce_tick_camera_distance
	distance_check_ticks = randi() % camera_distance_tick_rate
	idle_ticks = randi() % reduced_tick_frames

var short_distance: bool = true
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if track_target_in_editor:
			track_target()
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
	
	distance_check_ticks = (distance_check_ticks + 1) % camera_distance_tick_rate
	if distance_check_ticks == 0:
		short_distance = camera.global_position.distance_squared_to(global_position) < reduce_tick_camera_distance_squared
	
	if short_distance:
		track_target()
	else:
		idle_ticks = (idle_ticks + 1) % reduced_tick_frames
		if idle_ticks == 0:
			track_target()

func track_target():
	global_transform = target.global_transform.translated_local(localOffset)
