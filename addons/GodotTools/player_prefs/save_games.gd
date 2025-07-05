extends Node

const SAVE_PATH: StringName = "user://saves"
var saves: Array[SaveData]

const QUICKSAVE_PATH: StringName = "%s/quicksave.json" % SAVE_PATH
var qs: SaveData

signal save_changed

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		var err := DirAccess.make_dir_absolute(SAVE_PATH)
		if err:
			printerr("Error creating directory %s" % SAVE_PATH)
			return

	saves = []
	for file_name in DirAccess.get_files_at(SAVE_PATH):
		var path := "%s/%s" % [SAVE_PATH, file_name]
		var sd: SaveData = SaveData.load(path)
		if path == QUICKSAVE_PATH:
			qs = sd
		else:
			saves.append(sd)

func get_all_saves() -> Array[SaveData]:
	var ret: Array[SaveData] = []
	if qs:
		ret.append(qs)
	ret.append_array(saves)
	ret.sort_custom(func(a: SaveData, b: SaveData): return a.time_saved > b.time_saved)
	return ret
	
## Same with get_all_saves(), except the SaveData can be edited
func get_mutable_saves() -> Array[SaveData]:
	var ret: Array[SaveData] = []
	ret.assign(get_all_saves().map(func(s: SaveData): return s.duplicate(true)))
	return ret

func quicksave(data: String) -> void:
	qs = SaveData.new(data)
	qs.name = "Quicksave"
	qs.save(QUICKSAVE_PATH)
	save_changed.emit()

func quickload() -> SaveData:
	return qs

# index of -1 or > get_all_saves().size() will create a new save
func save(data: String, index: int = -1, name: String = "") -> void:
	var sd: SaveData
	var all_saves: Array[SaveData] = get_all_saves()
	if index >= all_saves.size() or index < 0:
		sd = SaveData.new(data)
		saves.append(sd)
	else:
		sd = all_saves[index]

	if sd == qs:
		quicksave(data)
	else:
		var saves_index: int = saves.find(sd)
		sd = SaveData.new(data)
		sd.name = name
		saves[saves_index] = sd
		sd.save(_get_save_path(sd))
		save_changed.emit()

func delete(index: int) -> void:
	var sd: SaveData = get_all_saves()[index]
	if sd == qs:
		qs = null
		SaveData.remove(QUICKSAVE_PATH)
	else:
		saves.erase(sd)
		sd.remove(_get_save_path(sd))

	save_changed.emit()

func _get_save_path(sd: SaveData) -> String:
	return "%s/%s.json" % [SAVE_PATH, sd.time_saved]
