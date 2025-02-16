extends Slider

@export var bus_index : int

func _ready():
	AudioServer.set_bus_volume_db(bus_index, PlayerPrefs.get_value(get_key(), 0))
	value = AudioServer.get_bus_volume_db(bus_index)
	value_changed.connect(on_value_changed)

func on_value_changed(value: float):
	AudioServer.set_bus_volume_db(bus_index, value)
	PlayerPrefs.set_value(get_key(), value)

func get_key() -> String:
	return "Volume_%d" % bus_index
