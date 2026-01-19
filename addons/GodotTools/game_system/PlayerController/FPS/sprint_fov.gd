class_name SprintFov
extends Node

@export var base: Node
## How much to change the FOV when sprinting
@export var sprint_fov_change: float = 15
@export var fov_transition_duration: float = 0.1
@onready var stand_state: StandState = base.find_children("", "StandState")[0]
@onready var camera: Camera3D = stand_state.find_children("", "Camera3D")[0]
@onready var weapon_system: WeaponSystem = base.find_children("", "WeaponSystem")[0]

var original_fov: float

func _ready() -> void:
	original_fov = camera.fov
	Signals.safe_connect(self, stand_state.sprinting_changed, _on_sprinting_changed)
	_on_sprinting_changed(stand_state.sprinting)

var prev_velocity_length: float = 0
func _process(_delta: float) -> void:
	var current_velocity_length: float = (base.velocity as Vector3).length()
	if prev_velocity_length != current_velocity_length:
		prev_velocity_length = current_velocity_length
		_on_sprinting_changed(stand_state.sprinting)

var tween: Tween
func _on_sprinting_changed(sprinting: bool) -> void:
	# Don't mess with aiming FOV changes
	if weapon_system.gun and weapon_system.gun.aiming:
		return

	if tween:
		tween.kill()
		tween = null
	
	var target_fov: float
	if sprinting and (base.velocity as Vector3).length() > 0.1:
		target_fov = original_fov + sprint_fov_change
	else:
		target_fov = original_fov

	tween = create_tween()
	tween.tween_property(camera, "fov", target_fov, fov_transition_duration)
