extends Node3D

@export var stream: AudioStream

func spawn():
	var player = AudioStreamPlayer3D.new()
	player.position = global_position
	player.stream = stream
	player.autoplay = true
	player.finished.connect(func(): player.queue_free())
	get_tree().current_scene.add_child(player)
