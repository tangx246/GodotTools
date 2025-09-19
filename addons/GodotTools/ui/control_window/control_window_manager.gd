extends Node

var windows: Array[ControlWindow] = []

const base_layer: int = 64

func register(cl: CanvasLayer):
	windows.append(cl)
	focused(cl)

func unregister(cl: CanvasLayer):
	windows.erase(cl)

func focused(cl: CanvasLayer):
	windows.erase(cl)
	windows.append(cl)
	for i in range(windows.size()):
		var window = windows[i]
		window.layer = base_layer + i
