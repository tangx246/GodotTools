class_name CooldownAudioStreamPlayer3D
extends AudioStreamPlayer3D

@export var cooldown: float
var last_played: float = -1

func play(from_position: float = 0.0) -> void:
	var now: float = Time.get_unix_time_from_system()
	if now - last_played < cooldown:
		return

	super.play(from_position)
	last_played = now
