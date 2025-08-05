class_name DeathSound
extends AudioStreamPlayer3D

@export var root: Node
@onready var damageable: Damageable = root if root is Damageable else root.find_children("", "Damageable")[0]

func _ready() -> void:
	if stream:
		Signals.safe_connect(self, damageable.died, _on_death)
	else:
		queue_free()

func _on_death():
	play()
