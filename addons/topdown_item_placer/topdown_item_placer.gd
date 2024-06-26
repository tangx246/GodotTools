class_name TopdownItemPlacer
extends Node3D

signal placing_item(placing: bool, item_name: String)
signal placed_item(item: PlacedItem, global_pos: Vector3, global_rot: Vector3)

@export var ray_length : float = 1000

var _placing : bool = false:
	set(value):
		_placing = value
		placing_item.emit(_placing, _current_item.name if _current_item != null else "")

var _current_item : PlacedItem
var _current_item_preview_scene : Node3D

func _ready():
	_placing = false

func place_item_requested(item: PlacedItem):
	if _current_item == item:
		return
	cancel_item_placing()
	
	_current_item = item
	_current_item_preview_scene = item.preview_scene.instantiate()
	add_child(_current_item_preview_scene)
	_placing = true

func _input(event: InputEvent):
	if !_placing:
		return
	
	var mouse = event as InputEventMouse
	if mouse != null:
		# Only attempt to place on a successful physics raycast
		var space_state = get_world_3d().direct_space_state
		var camera = get_tree().root.get_camera_3d()
		var from = camera.project_ray_origin(mouse.position)
		var to = from + camera.project_ray_normal(mouse.position) * ray_length
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if result.size() > 0:
			_current_item_preview_scene.visible = true
			_current_item_preview_scene.position = result["position"]
		else:
			_current_item_preview_scene.visible = false
		
		if mouse.is_pressed() and mouse.button_mask == MOUSE_BUTTON_MASK_LEFT:
			placed_item.emit(_current_item, _current_item_preview_scene.global_position, _current_item_preview_scene.global_rotation)
		
	if event.is_action("ui_cancel"):
		cancel_item_placing()
		
	if event.is_action_pressed("Rotate Clockwise"):
		_current_item_preview_scene.rotate_y(deg_to_rad(90))

	if event.is_action_pressed("Rotate Counterclockwise"):
		_current_item_preview_scene.rotate_y(deg_to_rad(-90))
	
func cancel_item_placing():
	if _current_item_preview_scene != null:
		_current_item_preview_scene.queue_free()
		_current_item_preview_scene = null
	_current_item = null
	_placing = false
