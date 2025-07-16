class_name UtilityDecorator
extends AlwaysSucceedDecorator

@export var considerations: Array[Consideration]

@export var debug: bool = false

var utility: float = 0:
	set(value):
		var prev_utility = utility
		utility = clampf(value, 0, 1)
		if debug and prev_utility != utility:
			print("Utility for %s: %s" % [name, utility])

func _ready() -> void:
	for c in considerations:
		Signals.safe_connect(self, c.value_changed, calculate_utility.unbind(1))
	calculate_utility.call_deferred()

func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"UtilityDecorator")
	return classes

func calculate_utility() -> void:
	printerr("Unimplemented utility method")
