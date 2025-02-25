class_name TickingResource
extends Node

signal current_changed(prev: float, current: float)
signal max_changed(prev: float, current: float)
signal changed

@export var max: float = 100:
	set(value):
		var prev: float = max
		max = value
		max_changed.emit(prev, max)

		if max != prev:
			changed.emit()

@export var current: float = 100:
	set(value):
		var prev: float = current
		current = clampf(value, 0, max)
		current_changed.emit(prev, current)

		if current != prev:
			changed.emit()

## Emitted when the resource reaches 0
signal drained
## Emitted when the resource reaches a value greater than 0 after being drained
signal recovered

## Per second
@export var drain_rate: float = 1

func _enter_tree() -> void:
	current_changed.connect(_on_current_changed)
	
func _exit_tree() -> void:
	current_changed.disconnect(_on_current_changed)

func _on_current_changed(prev: float, current: float) -> void:
	if current <= 0 and prev > 0:
		set_process(false)
		drained.emit()
	elif current > 0 and prev <= 0:
		set_process(true)
		recovered.emit()

func _process(delta: float) -> void:
	current = current - (delta * drain_rate)
