class_name ImmediateConsumer
extends Consumer

func start_consumption(_consumable: Consumable, finished: Callable) -> void:
	finished.call()
