class_name Interactable
extends Node3D

@export var interact_time : float = 0
## If true, will only trigger the signal on authority. Otherwise, triggers everywhere
@export var authority_only: bool = true

signal interacted(interactor: Interactor)
signal no_param_interacted()

func _enter_tree() -> void:
	Signals.safe_connect(self, interacted, no_param_interacted.emit.unbind(1))

func interact(interactor: Interactor):
	interact_rpc.rpc(interactor.get_path())

@rpc("any_peer", "call_local", "reliable")
func interact_rpc(interactor_path: NodePath):
	var interactor := get_node(interactor_path) as Interactor
	if not interactor:
		return

	if (not authority_only) or is_multiplayer_authority():
		interacted.emit(interactor)
