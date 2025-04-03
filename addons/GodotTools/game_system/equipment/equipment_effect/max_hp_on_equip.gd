class_name MaxHpOnEquip
extends EquipmentEffect

@export var amount: float

func apply(root: Node) -> void:
	var damageable: Damageable = root.find_children("", "Damageable").pop_front()
	if damageable:
		damageable.max_hp += amount
		damageable.current_hp += amount
	else:
		printerr("No damageable in %s" % root.get_path())
	
func unapply(root: Node) -> void:
	var damageable: Damageable = root.find_children("", "Damageable").pop_front()
	if damageable:
		damageable.max_hp -= amount
		damageable.current_hp -= amount
	else:
		printerr("No damageable in %s" % root.get_path())
	
func get_text() -> String:
	if amount > 0:
		return "Increase max HP by {amount}".format({"amount": "%d" % amount})
	else:
		return "Decrease max HP by {amount}".format({"amount": "%d" % -amount})
