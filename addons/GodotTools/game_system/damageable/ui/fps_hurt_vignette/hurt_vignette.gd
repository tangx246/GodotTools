class_name HurtVignette
extends TextureRect

@export var duration: float = 0.5
@export var root: Node3D
@onready var damageable: Damageable = root.find_children("", "Damageable")[0]

var gradient_texture = texture as GradientTexture2D
var gradient = gradient_texture.gradient as Gradient

func _ready() -> void:
	damageable.current_hp_changed_by_source.connect(_oh_hp_changed)
	gradient.set_offset(0, 1)
	
var tween: Tween
func _oh_hp_changed(prev_value: float, value: float, source: Node):
	if value >= prev_value:
		return
		
	if tween:
		tween.kill()
	
	var hurt_direction: Vector3 = Plane.PLANE_XZ.project(((source as Node3D).global_position - root.global_position)).normalized() if source is Node3D else root.global_position
	var basis_hurt_direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, -root.global_basis.z.signed_angle_to(hurt_direction, Vector3.UP))
	var x: float = lerpf(1, 0, (basis_hurt_direction.x + 1) / 2)
	var y: float = lerpf(0, 0.5, (basis_hurt_direction.z + 1) / 2)
	var fill_from: Vector2 = Vector2(x, y)
	#print("Hurt direction %s %s" % [hurt_direction, fill_from])
	gradient_texture.fill_from = fill_from
	
	tween = create_tween()
	tween.tween_method(func(input):
		gradient.set_offset(0, input), 0.0, 1.0, duration)
