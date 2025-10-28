extends TextureRect

@export var viewport_root: Node
## Size of each zoom step
@export var zoom_step_size: float = 10
## Number of steps to be able to zoom in
@export var max_zoom_in_steps: int = 2
## Number of steps to be able to zoom out
@export var max_zoom_out_steps: int = 5

var current_steps: int = 0
var camera: Camera3D
var initial_size: float

func _ready() -> void:
	var vp_texture: ViewportTexture = (viewport_root.find_children("", "Viewport", true, false)[0] as Viewport).get_texture()
	texture = vp_texture

	camera = viewport_root.find_children("", "Camera3D", true, false)[0] as Camera3D
	initial_size = camera.size

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Zoom In Minimap"):
		zoom_in()
	elif event.is_action_pressed("Zoom Out Minimap"):
		zoom_out()

func zoom_in() -> void:
	if current_steps > -max_zoom_in_steps:
		current_steps -= 1
		_refresh()

func zoom_out() -> void:
	if current_steps < max_zoom_out_steps:
		current_steps += 1
		_refresh()

func _refresh() -> void:
	camera.size = initial_size + current_steps * zoom_step_size
