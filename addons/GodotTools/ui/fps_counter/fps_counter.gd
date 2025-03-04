extends Control

@onready var fps_label : Label = %FPSCounter

func _process(_delta: float) -> void:
	fps_label.text = "%d" % Performance.get_monitor(Performance.Monitor.TIME_FPS)
