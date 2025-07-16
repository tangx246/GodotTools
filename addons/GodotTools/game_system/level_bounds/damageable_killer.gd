extends Node

var lb: LevelBounds

func _ready() -> void:
	lb = $".."
	Signals.safe_connect(self, lb.exited_bounds, _on_exited_bounds)

func _on_exited_bounds(body: Node):
	if is_instance_valid(body) and not body.is_queued_for_deletion() and body is Damageable:
		body.damage(body.current_hp, self, true)
	else:
		printerr("Body %s is not damageable" % body)
