class_name Interactor
extends Node3D

@export var actor: Node3D
@export_flags_3d_physics var collision_mask: int
@export var shape: Shape3D

var interactable : Interactable = null:
	set(value):
		interactable = value
		interactable_changed.emit(value)
var interact_progress : float = 0:
	set(value):
		interact_progress = value
		interact_progress_changed.emit(value)

@export_group("Synchronizable properties")
@export var interacting : bool = false:
	set(value):
		var previous = interacting
		interacting = value
		if previous != interacting:
			interacting_changed.emit()

signal interacting_changed
signal interactable_changed(interactable: Interactable)
signal interact_progress_changed(progress: float)

func _process(delta: float) -> void:
	if interactable and interacting:
		if interact_progress >= interactable.interact_time:
			interactable.interact(self)
			interacting = false
			interact_progress = 0
			return
		interact_progress += delta

func _unhandled_input(event: InputEvent) -> void:
	if interactable and event.is_action_pressed("interact"):
		interacting = true
	if event.is_action_released("interact"):
		interacting = false
		interact_progress = 0

var shapecast: ShapeCast3D

func _ready() -> void:
	shapecast = ShapeCast3D.new()
	shapecast.collision_mask = collision_mask
	shapecast.shape = shape
	add_child(shapecast)
	
func _physics_process(_delta: float) -> void:
	if shapecast.is_colliding():
		var body = shapecast.get_collider(0)
		if is_instance_valid(body) and not body.is_queued_for_deletion():
			interactable = _get_interactable(body, true)
	else:
		interactable = null

func _get_interactable(body: Node, error_on_no_interactable: bool) -> Interactable:
	if body is Interactable:
		return body
	else:
		var children = body.find_children("", "Interactable")
		if children.size() > 0:
			return children[0]
		else:
			var cousins = body.get_parent().find_children("", "Interactable")
			if cousins.size() > 0:
				return cousins[0]

	if error_on_no_interactable:
		push_error("Unable to find interactable in %s" % body)
	return null
