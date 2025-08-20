@tool
class_name Area3DDamageableKiller
extends Area3D

func _ready() -> void:
	monitorable = false
	collision_layer = 0
	Signals.safe_connect(self, body_entered, _on_entered)

func _on_entered(body: Node):
	if is_instance_valid(body) and not body.is_queued_for_deletion() and body is Damageable:
		body.damage(body.current_hp, self, true)
	else:
		printerr("Body %s is not damageable" % body)
