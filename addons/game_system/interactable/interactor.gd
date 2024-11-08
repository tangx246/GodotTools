class_name Interactor
extends Area3D

@export var actor : Node3D

var interactable : Interactable = null:
	set(value):
		interactable = value
		interactable_changed.emit(value)
var interacting : bool = false
var interact_progress : float = 0:
	set(value):
		interact_progress = value
		interact_progress_changed.emit(value)

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

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node3D):
	interactable = _get_interactable(body, true)
	print("Interactable %s" % interactable)

func _on_exit(body: Node3D):
	if interactable == _get_interactable(body, false):
		interactable = null

func _get_interactable(body: Node3D, error_on_no_interactable: bool) -> Interactable:
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
		printerr("Unable to find interactable in %s" % body)
	return null
