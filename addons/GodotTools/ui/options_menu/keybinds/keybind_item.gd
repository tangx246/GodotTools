class_name KeybindItem
extends HBoxContainer

@onready var label: Label = %Label
@onready var events_list: Control = %Events
@onready var add_button: Button = %Add
@onready var popup: PopupPanel = %PopupPanel

const KEY_FORMAT: String = "Keybind_%s"

var action: StringName:
	set(value):
		action = value
		_load_if_available()
		_refresh_action()

func _ready() -> void:
	set_process_input(false)

	Signals.safe_connect(self, add_button.pressed, _on_bind_requested)
	popup.unfocusable = true

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		InputMap.action_add_event(action, event)
		set_process_input(false)
		_refresh_action()
		popup.hide()
		_save()

func _load_if_available():
	var raw = PlayerPrefs.get_value(_get_formatted_key(), null)
	if raw == null:
		return
	var parsed: PackedByteArray = raw.hex_decode()

	var events: Array[InputEvent] = bytes_to_var_with_objects(parsed)
	if events != InputMap.action_get_events(action):
		InputMap.action_erase_events(action)
		for event in events:
			InputMap.action_add_event(action, event)

func _save():
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	var serialized: PackedByteArray = var_to_bytes_with_objects(events)
	var stringified: String = serialized.hex_encode()
	PlayerPrefs.set_value(_get_formatted_key(), stringified)

func _get_formatted_key() -> String:
	return KEY_FORMAT % action

func _on_bind_requested():
	set_process_input(true)
	popup.show()

func _refresh_action() -> void:        
	label.text = action.capitalize()
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	
	for child: Node in events_list.get_children():
		child.queue_free()

	for event: InputEvent in events:
		var new: Button = Button.new()
		new.text = event.as_text()
		new.pressed.connect(_remove_keybind.bind(event))
		events_list.add_child(new)

func _remove_keybind(event: InputEvent):
	InputMap.action_erase_event(action, event)
	_refresh_action()
	_save()

func reset():
	PlayerPrefs.delete_key(_get_formatted_key(), false)
