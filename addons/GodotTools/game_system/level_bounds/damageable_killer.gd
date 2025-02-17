extends Node

var lb: LevelBounds

func _enter_tree() -> void:
	lb = $".."
	lb.exited_bounds.connect(_on_exited_bounds)
	
func _exit_tree() -> void:
	lb.exited_bounds.disconnect(_on_exited_bounds)

func _on_exited_bounds(body: Node):
	if is_instance_valid(body) and not body.is_queued_for_deletion() and body is Damageable:
		body.damage(body.current_hp)
	else:
		printerr("Body %s is not damageable" % body)
