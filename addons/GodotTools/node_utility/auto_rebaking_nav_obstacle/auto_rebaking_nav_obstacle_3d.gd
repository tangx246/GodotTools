class_name AutoRebakingStaticNavigationObstacle3D
extends NavigationObstacle3D

var nav_regions: Array
func _ready() -> void:
	if affect_navigation_mesh or carve_navigation_mesh:
		assert(radius == 0, "Radius should equal 0")
		nav_regions = get_tree().current_scene.find_children("", "NavigationRegion3D", true, false)
		for nav_region: NavigationRegion3D in nav_regions:
			var duplicated = duplicate(true)
			nav_region.add_child(duplicated)
			nav_region.navigation_mesh = nav_region.navigation_mesh.duplicate(true)
			duplicated.global_transform = global_transform
		_rebake_navmesh.call_deferred()

var last_called: int = -1
func _rebake_navmesh() -> void:
	var current_frame: int = Engine.get_process_frames()
	if current_frame == last_called:
		return
	last_called = current_frame

	for nav_region in nav_regions:
		nav_region.bake_navigation_mesh()
		
	queue_free()
