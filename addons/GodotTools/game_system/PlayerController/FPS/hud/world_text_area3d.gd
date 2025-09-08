class_name WorldTextArea3D
extends Area3D

@export_multiline var text: String:
	set(value):
		var prev_text = text
		text = value
		if text != prev_text:
			text_changed.emit()
signal text_changed

func _ready() -> void:
	monitorable = false
	Signals.safe_connect(self, body_entered, _on_body_entered)
	Signals.safe_connect(self, body_exited, _on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	var world_text: WorldText = body.get_node(WorldText.NODEPATH)

	world_text.text = text
	world_text.visible = true

func _on_body_exited(body: Node3D) -> void:
	var world_text: WorldText = body.get_node(WorldText.NODEPATH)

	world_text.text = ""
	world_text.visible = false
