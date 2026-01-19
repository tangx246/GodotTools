class_name HurtSound
extends CooldownAudioStreamPlayer3D

@export var root: Node
@onready var damageable: Damageable = root if root is Damageable else root.find_children("", "Damageable")[0]

var saved_current_hp: float
func _ready() -> void:
	if stream:
		Signals.safe_connect(self, damageable.current_hp_reduced, _on_hurt, CONNECT_DEFERRED)
		saved_current_hp = damageable.current_hp
	else:
		queue_free()

func _on_hurt():
	if not damageable.is_dead() and damageable.current_hp < saved_current_hp:
		super.play()

	saved_current_hp = damageable.current_hp
