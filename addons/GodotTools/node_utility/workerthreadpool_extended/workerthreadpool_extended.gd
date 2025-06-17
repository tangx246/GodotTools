extends Node

var task_ids: Array[int]

var waiter_thread: Thread

func _enter_tree():
	task_ids = []
	waiter_thread = Thread.new()

func _cleaner(working_task_ids: Array[int]):
	for task_id in working_task_ids:
		WorkerThreadPool.wait_for_task_completion(task_id)

func _exit_tree():
	if waiter_thread.is_started():
		waiter_thread.wait_to_finish()

func _process(_delta: float) -> void:
	if not waiter_thread.is_alive() and task_ids.size() > 0:
		if waiter_thread.is_started():
			waiter_thread.wait_to_finish()
		waiter_thread.start(_cleaner.bind(task_ids.duplicate()))
		task_ids.clear()

## Does WorkerThreadPool.add_task, but you just fire and forget
func add_task(action: Callable, high_priority: bool = false, description: String = ""):
	var task_id: int = WorkerThreadPool.add_task(action, high_priority, description)
	_add_task_id(task_id)

func _add_task_id(task_id: int):
	task_ids.append(task_id)
