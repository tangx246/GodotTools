class_name FourDirectionAnimatedSprite2D
extends AnimatedSprite2D

@export var root: NavigationNode2D
@export var direction: Direction = Direction.DOWN:
	set(value):
		direction = value
		direction_changed.emit()
signal direction_changed

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT
}

func _ready() -> void:
	direction_changed.connect(_on_direction_changed)

func _on_direction_changed() -> void:
	flip_h = direction == Direction.LEFT

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		if root.velocity.is_equal_approx(Vector2.ZERO):
			direction = Direction.DOWN
			return
		
		var move_direction: Vector2 = root.velocity.normalized()
		var dot: float = move_direction.dot(Vector2.DOWN)
		if dot >= 0.5:
			direction = Direction.DOWN
		elif dot <= -0.5:
			direction = Direction.UP
		else:
			var left_dot: float = move_direction.dot(Vector2.LEFT)
			if left_dot > 0:
				direction = Direction.LEFT
			else:
				direction = Direction.RIGHT
