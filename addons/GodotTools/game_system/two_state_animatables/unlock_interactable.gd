class_name UnlockInteractable
extends Node

@export var root: Node
@export_flags_3d_physics var interactable_layer: int
@onready var two_state_animatable: TwoStateAnimatable = root.find_children("", "TwoStateAnimatable")[0] if root is not TwoStateAnimatable else root
@onready var collision_object: CollisionObject3D = root.find_children("", "CollisionObject3D")[0] if root is not CollisionObject3D else root
@onready var interactable: Interactable = root.find_children("", "Interactable")[0]

func _ready() -> void:
	Signals.safe_connect(self, interactable.interacted, _on_interacted)

func _on_interacted(_interactor: Node) -> void:
	if two_state_animatable.locked:
		unlock()
		collision_object.collision_layer &= ~interactable_layer

func unlock():
	two_state_animatable.locked = false
