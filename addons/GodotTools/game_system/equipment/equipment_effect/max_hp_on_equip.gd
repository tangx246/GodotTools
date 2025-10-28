class_name MaxHpOnEquip
extends EquipmentEffect

@export var amount: float

func apply(root: Node) -> void:
	var damageable: Damageable = root.find_children("", "Damageable").pop_front()
	if damageable:
		var current_ratio: float = damageable.current_hp / damageable.max_hp
		damageable.max_hp += amount
		damageable.current_hp = current_ratio * damageable.max_hp
	else:
		printerr("No damageable in %s" % root.get_path())
	
func unapply(root: Node) -> void:
	var damageable: Damageable = root.find_children("", "Damageable").pop_front()
	if damageable:
		var current_ratio: float = damageable.current_hp / damageable.max_hp
		damageable.max_hp -= amount
		damageable.current_hp = current_ratio * damageable.max_hp
	else:
		printerr("No damageable in %s" % root.get_path())
	
func get_text() -> String:
	if amount > 0:
		return "HP +{amount}".format({"amount": "%d" % amount})
	else:
		return "HP -{amount}".format({"amount": "%d" % -amount})

func get_effect_type() -> EffectType:
	if amount > 0:
		return EffectType.BUFF
	else:
		return EffectType.DEBUFF
