extends GutTest

const SaveGames = preload("uid://bsymgk2hf7kbh")

var sg: SaveGames
var double_kvs
var kvs: KeyValueStore

func before_each():
	sg = SaveGames.new()
	double_kvs = double(KeyValueStore)
	kvs = double_kvs.new("res://blah")
	sg.kvs = kvs

func test_get_all_saves_starts_empty() -> void:
	assert_eq(sg.get_all_saves(), [], "Starts empty")

func test_get_all_saves_sorted() -> void:
	var sd1: SaveData = SaveData.new("")
	var sd2: SaveData = SaveData.new("")
	var sd3: SaveData = SaveData.new("")
	sd1.time_saved = 1
	sd2.time_saved = 2
	sd3.time_saved = 3
	sg.saves = [sd3, sd1, sd2]

	assert_eq(sg.get_all_saves(), [sd3, sd2, sd1], "Saves sorted")

func test_get_all_saves_with_quicksave() -> void:
	var sd1: SaveData = SaveData.new("")
	var sd2: SaveData = SaveData.new("")
	var sd3: SaveData = SaveData.new("")
	sd1.time_saved = 1
	sd2.time_saved = 2
	sd3.time_saved = 3
	sg.saves = [sd3, sd1, sd2]
	sg.quicksave("test")
	sg.qs.time_saved = 4

	assert_eq(sg.get_all_saves(), [sg.qs, sd3, sd2, sd1], "Includes quicksave")

func test_get_all_saves_with_quicksave_in_middle() -> void:
	var sd1: SaveData = SaveData.new("")
	var sd2: SaveData = SaveData.new("")
	var sd3: SaveData = SaveData.new("")
	sd1.time_saved = 1
	sd2.time_saved = 2
	sd3.time_saved = 3
	sg.saves = [sd3, sd1, sd2]
	sg.quicksave("test")
	sg.qs.time_saved = 2.5

	assert_eq(sg.get_all_saves(), [sd3, sg.qs, sd2, sd1], "Includes quicksave in middle")

func test_quicksave_quickload() -> void:
	var testdata: String = "Test"
	sg.quicksave(testdata)

	assert_eq(sg.quickload().data, testdata, "Quickload should be what was quicksaved")
	var all_saves = sg.get_all_saves()
	assert_eq(all_saves.size(), 1, "Only one save should exist")
	assert_eq(all_saves[0].data, testdata, "Quicksave should show up in all save list")

	sg.save("Quicksave", 0)
	all_saves = sg.get_all_saves()
	assert_eq(all_saves.size(), 1, "Quicksave should be overriden")
	assert_eq(all_saves[0].data, "Quicksave", "Quicksave should be overriden")

func test_save() -> void:
	sg.quicksave("Quicksave")
	sg.qs.time_saved = 1
	
	sg.save("Newsave", 1)
	sg.saves[0].time_saved = 2
	var all_saves = sg.get_all_saves()
	assert_eq(all_saves.size(), 2, "2 saves")
	assert_eq(all_saves[1].data, "Quicksave", "Quicksave should remain the same")
	assert_eq(all_saves[0].data, "Newsave", "New save")

	sg.save("Overwritequicksave", 1)
	sg.qs.time_saved = 3
	all_saves = sg.get_all_saves()
	assert_eq(get_data(all_saves), ["Overwritequicksave", "Newsave"])

	sg.save("Overwritenewsave", 1)
	sg.saves[0].time_saved = 4
	all_saves = sg.get_all_saves()
	assert_eq(get_data(all_saves), ["Overwritenewsave", "Overwritequicksave"])

func get_data(all_saves: Array[SaveData]) -> Array[String]:
	var retVal: Array[String] = []
	retVal.assign(all_saves.map(func(a): return a.data))
	return retVal
