class_name MovementSpeedOnEquip
extends EquipmentEffect

@export var speed_factor: float = 1

func apply(root: Node) -> void:
	var ss: StandState = root.find_children("", "StandState").pop_front()
	if not ss:
		return
	ss.walk_speed *= speed_factor
	ss.stand_speed *= speed_factor
	ss.sprint_speed *= speed_factor
	ss.crouch_speed *= speed_factor
	ss.prone_speed *= speed_factor
	ss.refresh_speed()
	
func unapply(root: Node) -> void:
	var ss: StandState = root.find_children("", "StandState").pop_front()
	if not ss:
		return
	ss.walk_speed /= speed_factor
	ss.stand_speed /= speed_factor
	ss.sprint_speed /= speed_factor
	ss.crouch_speed /= speed_factor
	ss.prone_speed /= speed_factor
	ss.refresh_speed()
	
func get_text() -> String:
	if speed_factor > 1:
		return "Movement Speed +{speed_factor}%".format({
			"speed_factor": "%.0f" % ((speed_factor - 1) * 100)
		})
	else:
		return "Movement Speed -{speed_factor}%".format({
			"speed_factor": "%.0f" % ((1 - speed_factor) * 100)
		})

func get_effect_type() -> EffectType:
	return EffectType.BUFF if speed_factor > 1 else EffectType.DEBUFF
