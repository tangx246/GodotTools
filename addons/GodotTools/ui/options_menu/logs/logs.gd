extends VBoxContainer

@onready var text_edit: TextEdit = %TextEdit
@onready var button: Button = %Button

const LOG_PATH: String = "user://logs"

var text: String

func _ready() -> void:
	Signals.safe_connect(self, visibility_changed, _refresh)
	Signals.safe_connect(self, button.pressed, _on_copy)
	_refresh()

func _refresh() -> void:
	if not is_visible_in_tree():
		return
	
	var texts: Array[String] = []
	var file_names: Array[String]= []
	file_names.assign(DirAccess.get_files_at(LOG_PATH))
	file_names.sort()
	file_names.reverse()
	file_names.push_front(file_names.pop_back())
	for file_name: String in file_names:
		var file_path: String = "%s/%s" % [LOG_PATH, file_name]
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		var last_modified: String = Time.get_datetime_string_from_unix_time(FileAccess.get_modified_time(file_path), true)
		var text: String = ">>>>>%s - Last modified %s\n%s" % [file_name, last_modified, file.get_as_text()]
		texts.append(text)	

	text = "\n".join(texts)
	if text.length() > 10000:
		text_edit.text = "Cannot display. Max log length exceeded. Use Copy to Clipboard for the full logs"
	else:
		text_edit.text = text

func _on_copy() -> void:
	DisplayServer.clipboard_set(text)
