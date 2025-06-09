class_name WeaponSway
extends Node3D

@export var root: FPSController
@export var sway_factor: float = 1
@export var recovery_factor: float = 0.2

func _ready() -> void:
	Signals.safe_connect(self, root.mouse_looked, _mouse_looked)

func _mouse_looked(x_angle: float, y_angle: float) -> void:
	rotate_y(x_angle * sway_factor)
	rotate_x(y_angle * sway_factor)

func _process(_delta: float) -> void:
	rotation = Vector3(lerpf(rotation.x, 0, recovery_factor), lerpf(rotation.y, 0, recovery_factor), lerpf(rotation.z, 0, recovery_factor))
