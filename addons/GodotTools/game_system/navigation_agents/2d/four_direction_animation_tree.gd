class_name FourDirectionAnimationTree
extends AnimationTree

@export var root: Node
@onready var four_direction_animatedsprite2d: FourDirectionAnimatedSprite2D = root.find_children("", "FourDirectionAnimatedSprite2D")[0]
var velocity: float:
	get():
		return root.velocity.length()
var direction: FourDirectionAnimatedSprite2D.Direction:
	get():
		return four_direction_animatedsprite2d.direction
