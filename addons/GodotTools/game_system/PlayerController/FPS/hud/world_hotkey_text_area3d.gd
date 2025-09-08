class_name WorldHotkeyTextArea3D
extends WorldTextArea3D

## Will replace instances of [hotkey] with the appropriate hotkey_map (e.g. "Foo [hotkey]" will get turned into "Foo [F]")
@export var hotkey_text_to_map: Dictionary[String, StringName] = {
	"[hotkey]": "interact"
}

func _ready() -> void:
	super()
	
	_refresh()
	Signals.safe_connect(self, text_changed, _refresh)

func _refresh() -> void:
	for hotkey_text in hotkey_text_to_map:
		var hotkey_map: StringName = hotkey_text_to_map[hotkey_text]
		var event: InputEvent = InputMap.action_get_events(hotkey_map)[0]
		var to_text: String = event.as_text().split(" (")[0]
		text = text.replace(hotkey_text, "[%s]" % to_text)
