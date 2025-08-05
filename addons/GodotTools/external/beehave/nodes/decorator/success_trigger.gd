@tool
class_name SuccessTriggerDecorator extends Decorator

## Will continue to return SUCCESS after SUCCESS has been triggered once
var succeeded: bool = false

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)

	if c != running_child:
		c.before_run(actor, blackboard)

	var response = c.tick(actor, blackboard)
	if can_send_message(blackboard):
		BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

	if c is ConditionLeaf:
		blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
		blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

	if response == RUNNING:
		running_child = c
		if c is ActionLeaf:
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))
		return RUNNING
	else:
		c.after_run(actor, blackboard)

		if response == SUCCESS:
			succeeded = true

		if succeeded:
			return SUCCESS
		
		return response

func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"SuccessTriggerDecorator")
	return classes
