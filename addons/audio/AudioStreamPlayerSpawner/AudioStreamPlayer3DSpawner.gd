extends Node3D

@export var stream: AudioStream
@export var add_to_root: bool = false

func spawn():
	spawn_rpc.rpc()
		
@rpc("call_local")
func spawn_rpc():
	var player = AudioStreamPlayer3D.new()
	player.stream = stream
	player.autoplay = true
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.finished.connect(func(): player.queue_free())
	if add_to_root:
		player.position = global_position
		get_tree().current_scene.add_child(player)
	else:
		player.position = position
		add_child(player)
