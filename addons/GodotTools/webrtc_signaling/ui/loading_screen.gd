class_name LoadScreen
extends CanvasLayer

@onready var status: Label = %Status
@onready var progress: ProgressBar = %ProgressBar
@export var state: State:
	set(value):
		state = value
		_on_state_changed()

const state_to_text: Dictionary[State, String] = {
	State.CLEANING_UP: "Cleaning up",
	State.LOADING_SCENE: "Loading scene",
	State.INITIALIZING_EVERYTHING: "Initializing everything"
}

enum State {
	CLEANING_UP,
	LOADING_SCENE,
	INITIALIZING_EVERYTHING
}

func _on_state_changed():
	status.text = state_to_text[state]
	progress.value = float(state) / State.size()
