## Consumes things immediately. WARNING: Since ImmediateConsumer is a Node, it must be freed when done
class_name ImmediateConsumer
extends Consumer

func start_consumption(_consumable: Consumable, finished: Callable) -> void:
	finished.call()
