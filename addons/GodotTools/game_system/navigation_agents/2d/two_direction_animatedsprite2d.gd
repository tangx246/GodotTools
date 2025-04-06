class_name TwoDirectionAnimatedSprite2D
extends AnimatedSprite2D

@export var root: NavigationNode2D

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		flip_h = root.move_velocity.normalized().dot(Vector2.LEFT) > 0
