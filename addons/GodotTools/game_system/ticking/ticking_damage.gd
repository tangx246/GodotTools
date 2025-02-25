class_name TickingDamage
extends Node

@export var damage_per_second: float = 10
## How many times per second should the damage tick
@export var damage_tick_rate: float = 1

@export var root: Node
@onready var damageable: Damageable = root.find_children("", "Damageable")[0]

var timer: Timer
func _ready() -> void:
	timer = Timer.new()
	timer.autostart = false
	timer.wait_time = damage_tick_rate
	timer.timeout.connect(func():
		damageable.damage(damage_per_second / damage_tick_rate, self, true)
	)
	add_child(timer)

func start() -> void:
	timer.start()

func stop() -> void:
	timer.stop()
