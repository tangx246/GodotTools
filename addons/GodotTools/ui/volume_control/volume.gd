extends Slider

@export var bus_name : String

func _ready():
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		get_parent().visible = false
		return
	AudioServer.set_bus_volume_db(bus_index, PlayerPrefs.get_value(get_key(), 0))
	value = AudioServer.get_bus_volume_db(bus_index)
	value_changed.connect(on_value_changed)

func on_value_changed(value: float):
	var bus_index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, value)
	PlayerPrefs.set_value(get_key(), value)

func get_key() -> String:
	return "Volume_%s" % bus_name
