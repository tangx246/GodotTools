class_name TPSCamera
extends SpringArm3D

## Horizontal offset for over-the-shoulder view. Positive = right shoulder.
@export var shoulder_offset: float = 0.5
## Distance behind the player
@export var camera_distance: float = 2.5
## Collision margin to prevent clipping
@export var collision_margin: float = 0.1
## Reference to the player body to exclude from spring arm collision
@export var player_body: CharacterBody3D

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	spring_length = camera_distance
	self.margin = collision_margin
	camera.position.x = shoulder_offset
	if player_body:
		add_excluded_object(player_body.get_rid())

func set_shoulder_side(right: bool) -> void:
	shoulder_offset = absf(shoulder_offset) if right else -absf(shoulder_offset)
	if camera:
		camera.position.x = shoulder_offset
