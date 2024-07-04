## Extend this class to add useful metadata for classes consuming this Resource
class_name PlacedItem
extends Resource

## Scene that will follow the mouse around as it is being placed
@export var preview_scene : PackedScene
## Scene to be placed
@export var placed_scene : PackedScene
@export var name : String
