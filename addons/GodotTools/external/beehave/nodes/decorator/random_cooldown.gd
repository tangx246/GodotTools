@tool
extends CooldownDecorator
class_name RandomCooldownDecorator

## Amount of random time from 0 to random_time to add to the wait_time
@export var random_time: float = 0.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c = get_child(0)
	var remaining_time = blackboard.get_value(cache_key, 0.0, str(actor.get_instance_id()))
	var response

	if c != running_child:
		c.before_run(actor, blackboard)

	if remaining_time > 0:
		response = FAILURE

		remaining_time -= last_tick
		last_tick = 0
		blackboard.set_value(cache_key, remaining_time, str(actor.get_instance_id()))

		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(self.get_instance_id(), response)
	else:
		response = c.tick(actor, blackboard)

		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		if response == RUNNING:
			running_child = c
			if c is ActionLeaf:
				blackboard.set_value("running_action", c, str(actor.get_instance_id()))

		if response != RUNNING:
			blackboard.set_value(cache_key, wait_time + randf_range(0, random_time), str(actor.get_instance_id()))
			c.after_run(actor, blackboard)

	return response
