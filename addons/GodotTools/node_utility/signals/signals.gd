class_name Signals

static func safe_connect(base: Node, sig: Signal, callable: Callable, flags: int = 0) -> void:
	if not base.is_inside_tree():
		print("%s is not inside tree" % base.name)
		return
	
	if not sig.is_connected(callable):
		sig.connect(callable, flags)
	
	base.tree_exiting.connect(func():
		if sig.get_object() and sig.is_connected(callable):
			sig.disconnect(callable)
	, CONNECT_ONE_SHOT)
