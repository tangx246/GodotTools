class_name Consideration
extends Node

@export var root: Node
## Tick every [member tick_rate] seconds
@export var tick_rate: float = 0.5
## Invert the value of this consideration (i.e. 1 - value) [br]
## e.g. 0.1 becomes 0.9
@export var invert: bool = false
@export var debug: bool = false

var value: float = 0:
	set(val):
		var prev_value: float = value
		value = _transform(clampf(val, 0, 1))
		if prev_value != value:
			value_changed.emit(value)
signal value_changed(value: float)

func _ready() -> void:
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = tick_rate
	Signals.safe_connect(self, timer.timeout, func(): tick(timer.wait_time))
	add_child(timer)

	set_process(debug)

func _process(_delta: float) -> void:
	if debug:
		print("%s: %.2f" % [name, value])

func tick(delta: float) -> void:
	assert(false, "Unimplemented")

func _transform(input: float) -> float:
	var transformed: float = input

	if invert:
		transformed = 1 - transformed

	return transformed
