extends MultiplayerSpawner

## Players spawn in first
@export var playerScene : PackedScene

## Emitted when the player is currently spawning, but before being added to the scene tree.
## Authority-related processing should happen here7yAFL
signal player_spawning(id: int, player: Node)

func _ready():
	spawn_function = _player_spawn
	if multiplayer.is_server():
		print("Connected peers: %s" % multiplayer.get_peers())
		for id in multiplayer.get_peers():
			spawn.call_deferred(id)

		# Make one for the server's self
		spawn.call_deferred(multiplayer.get_unique_id())

func _player_spawn(id: int):
	var instantiated = playerScene.instantiate()
	instantiated.set_multiplayer_authority(id)
	player_spawning.emit(id, instantiated)
	return instantiated
