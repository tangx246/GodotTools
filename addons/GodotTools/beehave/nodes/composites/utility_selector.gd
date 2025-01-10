@tool
class_name UtilitySelectorComposite
extends Composite

## UtilitySelectorComposite will attempt to select from each of its children the node that has
## the highest utility. This utility is provided by a UtilityDecorator

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()

	if get_children().filter(func(x): return x is not UtilityDecorator).size() > 0:
		warnings.append(
			"All children of UtilitySelectorComposite should be UtilityDecorator nodes."
		)

	return warnings

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c: UtilityDecorator = get_highest_utility_child()
	if c.utility <= 0:
		return FAILURE

	if c != running_child:
		c.before_run(actor, blackboard)

	var response = c.tick(actor, blackboard)
	if can_send_message(blackboard):
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

	match response:
		SUCCESS:
			# Interrupt any child that was RUNNING before.
			if c != running_child:
				interrupt(actor, blackboard)
			c.after_run(actor, blackboard)
		FAILURE:
			c.after_run(actor, blackboard)
		RUNNING:
			if c != running_child:
				interrupt(actor, blackboard)
				running_child = c
		_:
			printerr("Unhandled response %s" % response)

	return response

func get_highest_utility_child() -> UtilityDecorator:
	var highest_utility: float = -1
	var highest_utility_child: UtilityDecorator

	for c: UtilityDecorator in get_children():
		if c.utility > highest_utility:
			highest_utility = c.utility
			highest_utility_child = c

	return highest_utility_child

func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"UtilitySelectorComposite")
	return classes