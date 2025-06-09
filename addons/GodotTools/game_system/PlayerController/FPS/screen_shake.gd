class_name ScreenShake
extends Node3D

@export var shake_reduction_rate: float = 1
@export var noise : FastNoiseLite
@export var recovery_factor : float = 0.75

var _shake = 0:
	set(value):
		_shake = clampf(value, 0, 1)

func _process(delta: float) -> void:
	if _shake > 0:
		position += Vector3(
			noise.get_noise_2d(0, Time.get_ticks_msec()),
			noise.get_noise_2d(1, Time.get_ticks_msec()),
			0) * (_shake * _shake)
	
	position = Vector3(lerpf(position.x, 0, recovery_factor), lerpf(position.y, 0, recovery_factor), 0)
	_shake -= shake_reduction_rate * delta

## Shake goes from 0-1
func add_shake(shake: float):
	_shake += shake
