extends Node

var exit: bool = false

var task_ids_mutex: Mutex
var task_ids: Array[int]

var waiter_thread: Thread
var waiter_semaphore: Semaphore

func _enter_tree():
	task_ids_mutex = Mutex.new()
	waiter_semaphore = Semaphore.new()
	task_ids = []
	waiter_thread = Thread.new()
	waiter_thread.start(_cleaner_loop)

var working_task_ids: Array[int] = []
func _cleaner_loop():
	while true:
		waiter_semaphore.wait()
		
		task_ids_mutex.lock()
		working_task_ids.assign(task_ids)
		task_ids.clear()
		task_ids_mutex.unlock()
		
		for task_id in working_task_ids:
			WorkerThreadPool.wait_for_task_completion(task_id)
		
		working_task_ids.clear()
		
		if exit:
			break

func _exit_tree():
	exit = true
	waiter_semaphore.post()
	waiter_thread.wait_to_finish()

func _process(_delta: float) -> void:
	task_ids_mutex.lock()
	var clean_up: bool = task_ids.size() > 1
	task_ids_mutex.unlock()
	if clean_up:
		waiter_semaphore.post()

## Does WorkerThreadPool.add_task, but you just fire and forget
func add_task(action: Callable, high_priority: bool = false, description: String = ""):
	var task_id: int = WorkerThreadPool.add_task(action, high_priority, description)
	_add_task_id.call_deferred(task_id)

func _add_task_id(task_id: int):
	task_ids_mutex.lock()
	task_ids.append(task_id)
	task_ids_mutex.unlock()
