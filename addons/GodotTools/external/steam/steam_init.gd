extends Node

const MULTIPROCESS_APP_ID_PATH: String = "res://dedicated_server_steamappid.txt"
const APP_ID_PATH: String = "res://steam_appid.txt"
const DEMO_APP_ID_PATH: String = "res://demo_steamappid.txt"
var _Steam = Engine.get_singleton("Steam")

func _ready() -> void:
	var steam_app_id: int = _get_steam_app_id()

	if _Steam:
		var resp = _Steam.steamInitEx(steam_app_id, true)
		if resp['status'] > _Steam.STEAM_API_INIT_RESULT_OK:
			print("Unable to initialize Steam: %s" % JSON.stringify(resp))
			_Steam = null

func get_steam() -> Object:
	if not _Steam:
		return null
	
	if _Steam and _Steam.loggedOn():
		return _Steam
	
	return null

func _get_steam_app_id() -> int:
	#var is_multiprocess_instance: bool = Multiprocess.is_multiprocess_instance()
	var is_demo: bool = OS.has_feature("demo")
	
	var app_id_path: String
	if is_demo:
		app_id_path = DEMO_APP_ID_PATH
	else:
		app_id_path = APP_ID_PATH
	
	var file_access: FileAccess = FileAccess.open(app_id_path, FileAccess.READ)
	if not file_access:
		push_error("Unable to open file at path %s - %s" % [app_id_path, FileAccess.get_open_error()])
		return 0

	var app_id_str: String = file_access.get_as_text().strip_edges()
	return int(app_id_str)
