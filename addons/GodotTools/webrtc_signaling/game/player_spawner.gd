class_name PlayerSpawner
extends MultiplayerSpawner

## Players spawn in first
@export var playerScene : PackedScene
@export var shifter: SpawnerShifter

const group : StringName = "PlayerSpawner"

## Emitted when the player is currently spawning, but before being added to the scene tree.
## Authority-related processing should happen here
signal player_spawning(id: int, player: Node)

func _init() -> void:
	add_to_group(group)

func _ready():
	spawn_function = _player_spawn
	if is_multiplayer_authority():
		print("Connected peers: %s" % multiplayer.get_peers())
		for id: int in multiplayer.get_peers():
			spawn.call_deferred(id)

		# Make one for the server's self
		spawn.call_deferred(multiplayer.get_unique_id())

func _player_spawn(id: int):
	var instantiated = playerScene.instantiate()
	if shifter:
		shifter.shift(instantiated)
	instantiated.set_multiplayer_authority(id)
	player_spawning.emit(id, instantiated)
	return instantiated
