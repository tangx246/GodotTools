class_name SplashScreen
extends Control

@export var images: Array[Texture2D] = []
@export var duration_per_image_seconds: float = 2
@export var fade_time: float = 0.5
@export var skip_actions: Array[StringName] = ["ui_cancel", "ui_accept"]
@export_file("*.tscn") var next_scene: String

@onready var tr: TextureRect = %TextureRect
var loaded_next_scene: PackedScene

func _ready() -> void:
	loaded_next_scene = load(next_scene)
	
	if not Multiprocess.is_multiprocess_instance():
		for image in images:
			tr.modulate.a = 0
			tr.texture = image
			var tween = create_tween()
			tween.tween_property(tr, "modulate:a", 1, fade_time)
			await tween.finished
			await get_tree().create_timer(duration_per_image_seconds).timeout
			tween = create_tween()
			tween.tween_property(tr, "modulate:a", 0, fade_time)
			await tween.finished

	_transition_scene()

func _unhandled_input(event: InputEvent) -> void:
	for action in skip_actions:
		if event.is_action(action):
			_transition_scene()
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
			_transition_scene()

func _transition_scene() -> void:
	get_tree().change_scene_to_packed.call_deferred(loaded_next_scene)
