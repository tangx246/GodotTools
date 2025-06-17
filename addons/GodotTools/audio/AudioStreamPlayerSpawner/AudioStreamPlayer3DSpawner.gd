extends Node3D

@export var stream: AudioStream
@export var add_to_root: bool = false

var player: AudioStreamPlayer3D
func _enter_tree() -> void:
	player = AudioStreamPlayer3D.new()
	player.stream = stream
	player.autoplay = false
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	if add_to_root:
		get_tree().current_scene.add_child(player)
	else:
		add_child(player)

func _exit_tree() -> void:
	player.queue_free()

func spawn():
	if is_multiplayer_authority():
		spawn_rpc.rpc()
		
@rpc("call_local")
func spawn_rpc():
	if add_to_root:
		player.global_position = global_position
	player.play()
