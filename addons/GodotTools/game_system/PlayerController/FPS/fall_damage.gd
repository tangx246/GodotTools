class_name FallDamage
extends Node

@export var root: FPSController
## x-axis is the fall height. y-axis is how much damage the player takes
@export var fall_damage_curve: Curve
@onready var damageable: Damageable = root.find_children("", "Damageable")[0]

func _enter_tree() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	
	if not root.hit_floor.is_connected(_on_fell):
		root.hit_floor.connect(_on_fell)
	
func _exit_tree() -> void:
	if root.hit_floor.is_connected(_on_fell):
		root.hit_floor.disconnect(_on_fell)

func _on_fell(fall_speed: float, fall_height: float):
	if fall_speed > 0:
		damageable.damage(fall_damage_curve.sample_baked(fall_height),
			self, true)
		#print("Fall speed: %s. Fell from: %s" % [fall_speed, fall_height])
