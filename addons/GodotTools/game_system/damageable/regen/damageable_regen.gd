class_name DamageableRegen
extends Node

## How much HP to regenerate per tick
@export var regen_amount: float = 0.0:
	set(value):
		regen_amount = value
		if regen_amount > 0:
			_start_timer()
		else:
			_stop_timer()

## How many times per second to regenerate
@export var tick_rate: float = 1.0:
	set(value):
		tick_rate = value
		if tick_rate > 0 and is_instance_valid(timer):
			timer.wait_time = 1.0 / tick_rate

@onready var damageable: Damageable = get_parent()
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_regen_tick)
	self.regen_amount = regen_amount # Trigger the setter
	self.tick_rate = tick_rate # Trigger the setter

func _on_regen_tick() -> void:
	if regen_amount > 0 and is_instance_valid(damageable) and not damageable.is_dead():
		damageable.damage(-regen_amount, self)

func _start_timer() -> void:
	if not is_instance_valid(timer):
		return
	if tick_rate > 0:
		timer.wait_time = 1.0 / tick_rate
		timer.start()

func _stop_timer() -> void:
	if not is_instance_valid(timer):
		return
	timer.stop()
