extends VBoxContainer

@onready var text_edit: TextEdit = %TextEdit
@onready var button: Button = %Button

const LOG_PATH: String = "user://logs"

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
		var text: String = ">>>>>%s\n%s" % [file_name, file.get_as_text()]
		texts.append(text)	

	text_edit.text = "\n".join(texts)

func _on_copy() -> void:
	DisplayServer.clipboard_set(text_edit.text)
