class_name Interactor
extends Area3D

var interactable : Interactable = null

func _unhandled_input(event: InputEvent) -> void:
	if interactable and event.is_action_pressed("interact"):
		interactable.interact(self)

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

	if error_on_no_interactable:
		printerr("Unable to find interactable in %s" % body)
	return null
