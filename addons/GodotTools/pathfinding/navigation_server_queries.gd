extends Node

var queryParams: NavigationPathQueryParameters3D
var queryResult: NavigationPathQueryResult3D

func _ready() -> void:
	queryParams = NavigationPathQueryParameters3D.new()	
	queryResult = NavigationPathQueryResult3D.new()

func has_path_to(navAgent: NavigationAgent3D, startPos: Vector3, targetPos: Vector3) -> bool:
	queryParams.map = navAgent.get_navigation_map()
	queryParams.metadata_flags = navAgent.path_metadata_flags
	queryParams.navigation_layers = navAgent.navigation_layers
	queryParams.path_postprocessing = navAgent.path_postprocessing
	queryParams.pathfinding_algorithm = navAgent.pathfinding_algorithm

	queryResult.reset()
	queryParams.start_position = startPos
	queryParams.target_position = targetPos
	NavigationServer3D.query_path(queryParams, queryResult)
	
	var pathFoundDistanceToTarget: float = INF if queryResult.path.size() == 0 else queryResult.path[-1].distance_to(targetPos)
	return pathFoundDistanceToTarget < navAgent.target_desired_distance
