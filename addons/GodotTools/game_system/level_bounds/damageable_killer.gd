extends Node

@onready var lb: LevelBounds = $".."

func _ready() -> void:
	lb.exited_bounds.connect(_on_exited_bounds)

func _on_exited_bounds(body: Node):
	if body is Damageable:
		body.damage(body.current_hp)
	else:
		printerr("Body %s is not damageable" % body)
