extends Control

@onready var bind_list: Control = %BindList
@onready var reset_to_defaults: Button = %Reset
@export var keybind_item: PackedScene

func _ready():
	for child in bind_list.get_children():
		child.queue_free()	
	
	var actions: Array[StringName] = InputMap.get_actions()
	for action: StringName in actions:
		if action.begins_with("ui"):
			continue
		var item: KeybindItem = keybind_item.instantiate()
		bind_list.add_child(item)
		item.action = action

	Signals.safe_connect(self, reset_to_defaults.pressed, _on_reset_to_defaults)
		
func _on_reset_to_defaults() -> void:
	for child in bind_list.get_children():
		var item: KeybindItem = child
		item.reset()

	PlayerPrefs.save()
	InputMap.load_from_project_settings()
	_ready()
