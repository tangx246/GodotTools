class_name AverageUtilityDecorator
extends UtilityDecorator

func calculate_utility() -> void:
	var total: float = 0
	for c in considerations:
		total += c.value

	utility = total / considerations.size()