class_name RandomAudioStreamPlayer3D
extends AudioStreamPlayer3D

@export var streams : Array[AudioStream]

func _ready() -> void:
	stream = streams[randi_range(0, streams.size() - 1)]
	if autoplay:
		play()
