class_name Signals

static var node_to_callable_to_signal_funcs: Dictionary[Node, Dictionary] = {}

class SignalFuncs extends RefCounted:
	var connect_signal_func: Callable
	var disconnect_signal_func: Callable

static func safe_connect(base: Node, sig: Signal, callable: Callable, flags: int = 0) -> void:
	var connect_signal_func: Callable = func():
		if not sig.is_connected(callable):
			sig.connect(callable, flags)
	if not base.tree_entered.is_connected(connect_signal_func):
		base.tree_entered.connect(connect_signal_func)

	if is_instance_valid(base) and not base.is_queued_for_deletion() and base.is_inside_tree():
		connect_signal_func.call()
	
	var disconnect_signal_func: Callable = func():
		if sig.get_object() and sig.is_connected(callable):
			sig.disconnect(callable)

		if not is_instance_valid(base) or base.is_queued_for_deletion():
			safe_disconnect(base, sig, callable)

	if not base.tree_exiting.is_connected(disconnect_signal_func):
		base.tree_exiting.connect(disconnect_signal_func)
		
	_attach_metadata(base, callable, connect_signal_func, disconnect_signal_func)

static func _attach_metadata(base: Node, callable: Callable, connect_signal_func: Callable, disconnect_signal_func: Callable) -> void:
	var callable_to_signal_funcs := _get_callable_to_signal_funcs(base)
	var signalfuncs: SignalFuncs = SignalFuncs.new()
	signalfuncs.connect_signal_func = connect_signal_func
	signalfuncs.disconnect_signal_func = disconnect_signal_func
	callable_to_signal_funcs[callable] = signalfuncs
	node_to_callable_to_signal_funcs[base] = callable_to_signal_funcs

static func _get_callable_to_signal_funcs(base: Node) -> Dictionary[Callable, SignalFuncs]:
	var callable_to_signal_funcs: Dictionary[Callable, SignalFuncs]
	if node_to_callable_to_signal_funcs.has(base):
		callable_to_signal_funcs = node_to_callable_to_signal_funcs[base]
	else:
		callable_to_signal_funcs = {}
	return callable_to_signal_funcs

static func safe_disconnect(base: Node, sig: Signal, callable: Callable) -> void:
	var callable_to_signal_funcs := _get_callable_to_signal_funcs(base)
	if callable_to_signal_funcs.has(callable):
		var signalfuncs: SignalFuncs = callable_to_signal_funcs[callable]
		var connect_signal_func: Callable = signalfuncs.connect_signal_func
		var disconnect_signal_func: Callable = signalfuncs.disconnect_signal_func
		
		if base.tree_entered.is_connected(connect_signal_func):
			base.tree_entered.disconnect(connect_signal_func)
		if base.tree_exiting.is_connected(disconnect_signal_func):
			base.tree_exiting.disconnect(disconnect_signal_func)
		callable_to_signal_funcs.erase(callable)
		if callable_to_signal_funcs.size() == 0:
			node_to_callable_to_signal_funcs.erase(base)
		else:
			node_to_callable_to_signal_funcs[base] = callable_to_signal_funcs

	if sig.is_connected(callable):
		sig.disconnect(callable)
