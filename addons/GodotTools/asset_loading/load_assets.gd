extends Node

func _init() -> void:
	if OS.has_feature("editor"):
		return
	
	_load("assets.zip")

func _load(path: String) -> void:
	print("Loading %s" % path)
	var success = ProjectSettings.load_resource_pack(OS.get_executable_path().get_base_dir().path_join(path))
	if not success:
		printerr("Load %s failed" % path)
