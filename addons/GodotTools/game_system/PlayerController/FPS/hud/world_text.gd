class_name WorldText
extends RichTextLabel

const NODEPATH: NodePath = ^"%WorldText"

func _ready() -> void:
	assert(name == "WorldText" and unique_name_in_owner, "Name must be WorldText and unique in owner")
	visible = false
