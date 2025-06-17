extends Node

var kvs: KeyValueStore = KeyValueStore.new("user://save_games.save")

const QUICKSAVE_KEY: String = "Quicksave"
var qs: SaveData

const SAVES_KEY: String = "Saves"
var saves: Array[SaveData]

signal save_changed

func _ready() -> void:
	var qs_string: String = kvs.get_value(QUICKSAVE_KEY, "")
	if !qs_string.is_empty():
		qs = SaveData.deserialize(qs_string)

	var saves_string: String = kvs.get_value(SAVES_KEY, "[]")
	var saves_parsed: Array = JSON.parse_string(saves_string)
	for i in range(saves_parsed.size()):
		saves_parsed[i] = SaveData.deserialize(saves_parsed[i])
	saves.assign(saves_parsed)

func get_all_saves() -> Array[SaveData]:
	var ret: Array[SaveData] = []
	if qs:
		ret.append(qs)
	ret.append_array(saves)
	ret.sort_custom(func(a: SaveData, b: SaveData): return a.time_saved > b.time_saved)
	return ret

func quicksave(data: String) -> void:
	qs = SaveData.new(data)
	qs.name = QUICKSAVE_KEY
	var stringified: String = qs.to_string()
	kvs.set_value(QUICKSAVE_KEY, stringified)
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

		var stringified: String = JSON.stringify(saves)
		kvs.set_value(SAVES_KEY, stringified)
		save_changed.emit()

func delete(index: int) -> void:
	var sd: SaveData = get_all_saves()[index]
	if sd == qs:
		qs = null
		kvs.set_value(QUICKSAVE_KEY, "")
		save_changed.emit()
	else:
		saves.erase(sd)
		kvs.set_value(SAVES_KEY, JSON.stringify(saves))
		save_changed.emit()
