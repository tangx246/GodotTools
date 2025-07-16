class_name FallDamage
extends Node

@export var root: FPSController
## x-axis is the fall height. y-axis is how much damage the player takes
@export var fall_damage_curve: Curve
@onready var damageable: Damageable = root.find_children("", "Damageable")[0]

func _ready() -> void:
	Signals.safe_connect(self, root.hit_floor, _on_fell)

func _on_fell(fall_speed: float, fall_height: float):
	if fall_speed > 0:
		damageable.damage(fall_damage_curve.sample_baked(fall_height),
			self, true)
		#print("Fall speed: %s. Fell from: %s" % [fall_speed, fall_height])
