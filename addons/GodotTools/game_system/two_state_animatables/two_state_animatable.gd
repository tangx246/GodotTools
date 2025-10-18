class_name TwoStateAnimatable
extends Node3D

var animation : AnimationPlayer
@export var open_animation : StringName
@export var close_animation : StringName
@export var open_on_ready : bool = false
@export var locked: bool = false:
	set(value):
		var prev: bool = locked
		locked = value
		if prev != locked:
			locked_changed.emit()

signal locked_changed

var _is_open: bool = false

func _enter_tree() -> void:
	# Initialize early in case other objects call this early
	animation = find_children("", "AnimationPlayer")[0]

func _ready():
	var _original_locked: bool = locked
	locked = false
	if open_on_ready:
		play_open()
	else:
		play_close()
	locked = _original_locked

func play_open():
	_play_anim(true)
	
func play_close():
	_play_anim(false)
	
func toggle_open():
	_play_anim(not is_open())

var awaiting : int = 0
func _play_anim(to_open : bool):
	if locked:
		return
	
	var animation_to_play := close_animation if not to_open else open_animation
	
	if animation.is_playing():
		awaiting = awaiting + 1
		await animation.animation_finished
		awaiting = awaiting - 1

	if is_open() != to_open and awaiting == 0:
		animation.play(animation_to_play)
		_is_open = to_open

func is_open() -> bool:
	return _is_open
