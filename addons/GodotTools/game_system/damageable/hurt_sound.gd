class_name HurtSound
extends CooldownAudioStreamPlayer3D

@export var root: Node
@onready var damageable: Damageable = root if root is Damageable else root.find_children("", "Damageable")[0]

func _ready() -> void:
	if stream:
		Signals.safe_connect(self, damageable.current_hp_reduced, _on_hurt)
	else:
		queue_free()

func _on_hurt():
	if not damageable.is_dead():
		super.play()
