class_name AutoRebakingStaticNavigationObstacle3D
extends NavigationObstacle3D

const NAVMESH_EXCLUDE_GROUP: StringName = "navmesh_exclude_group"

var nav_regions: Array
var duplicates: Array
func _ready() -> void:
	assert(radius == 0, "Radius should equal 0")
	nav_regions = get_tree().current_scene.find_children("", "NavigationRegion3D", true, false)
	for nav_region: NavigationRegion3D in nav_regions:
		var duplicated = duplicate(true)
		nav_region.add_child.call_deferred(duplicated)
		nav_region.navigation_mesh = nav_region.navigation_mesh.duplicate(true)
		duplicated.global_transform = global_transform
		duplicates.append(duplicated)

	if affect_navigation_mesh or carve_navigation_mesh:
		rebake_navmesh()

var rebake_queued: bool = false
func rebake_navmesh() -> void:
	if rebake_queued:
		return
	rebake_queued = true
	_rebake_navmesh.call_deferred()

func _rebake_navmesh() -> void:
	await Engine.get_main_loop().physics_frame
	rebake_queued = false

	for duplicate in duplicates:
		duplicate.avoidance_enabled = avoidance_enabled
		duplicate.carve_navigation_mesh = carve_navigation_mesh
		duplicate.affect_navigation_mesh = affect_navigation_mesh

	var prev_disabled: Dictionary[Node, bool] = {}
	for disabled in get_tree().get_nodes_in_group(NAVMESH_EXCLUDE_GROUP):
		prev_disabled[disabled] = disabled.disabled
		disabled.disabled = true

	for nav_region: NavigationRegion3D in nav_regions:
		if not nav_region.is_baking():
			nav_region.bake_navigation_mesh()

	# We usually wait for the bake to finish here, but there is then a race condition
	# when other bakes begin to queue up and disable the wrong things

	for disabled in prev_disabled:
		disabled.disabled = prev_disabled[disabled]
