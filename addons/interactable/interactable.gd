class_name Interactable
extends Node3D

@export var interact_time : float = 0

signal interacted(interactor: Interactor)

func interact(interactor: Interactor):
	interact_rpc.rpc(interactor.get_path())

@rpc("any_peer", "call_local", "reliable")
func interact_rpc(interactor_path: NodePath):
	var interactor := get_node(interactor_path) as Interactor
	if not interactor:
		return

	if is_multiplayer_authority():
		interacted.emit(interactor)
