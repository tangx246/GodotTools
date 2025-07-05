extends CanvasLayer

@onready var fps_label : Label = %FPSCounter

var ShowFpsOption = load("uid://c5x45fo5mbv0y")

func _ready() -> void:
	Signals.safe_connect(self, PlayerPrefs.value_changed, _on_pp_changed)
	if ShowFpsOption:
		_on_pp_changed(ShowFpsOption.SHOW_FPS_KEY)

func _on_pp_changed(key: String) -> void:
	if ShowFpsOption and key == ShowFpsOption.SHOW_FPS_KEY:
		visible = PlayerPrefs.get_value(ShowFpsOption.SHOW_FPS_KEY, false)

func _process(_delta: float) -> void:
	fps_label.text = "%d" % Performance.get_monitor(Performance.Monitor.TIME_FPS)
