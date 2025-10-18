class_name Door
extends TwoStateAnimatable

@export var doorway_collision_shape : CollisionShape3D
@onready var nav_obstacle: AutoRebakingStaticNavigationObstacle3D = find_children("", "AutoRebakingStaticNavigationObstacle3D").pop_front()

func _enter_tree() -> void:
	super()
	doorway_collision_shape.add_to_group(AutoRebakingStaticNavigationObstacle3D.NAVMESH_EXCLUDE_GROUP)

func _ready():
	super()

	if locked and not nav_obstacle:
		assert(false, "Locked doors need to have an AutoRebakingStaticNavigationObstacle3D where the doorway is supposed to be")
	if nav_obstacle:
		Signals.safe_connect(self, locked_changed, _on_locked_changed)
		_on_locked_changed()

func _on_locked_changed():
	nav_obstacle.affect_navigation_mesh = locked
	nav_obstacle.carve_navigation_mesh = locked
	nav_obstacle.avoidance_enabled = locked
	nav_obstacle.rebake_navmesh.call_deferred()

func is_open() -> bool:
	return doorway_collision_shape.disabled

## Called by Animator
func opened():
	doorway_collision_shape.disabled = true
	
## Called by Animator
func closed():
	doorway_collision_shape.disabled = false
