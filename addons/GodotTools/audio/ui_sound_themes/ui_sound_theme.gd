extends Node

@export var default_ui_theme: SoundTheme = preload("default_ui_theme.tres")
@export var default_ui_theme_group: StringName = "default_sound_theme"
@export var no_ui_theme_group: StringName = "no_sound_theme"
## Nodes inherit SoundThemes from their closest ancestor by Node.is_in_group()
@export var group_ui_themes: Array[SoundThemeGroup]
@onready var player: AudioStreamPlayer = %AudioStreamPlayer
var group_ui_themes_dict: Dictionary

func _ready():
	group_ui_themes_dict = {}
	for theme: SoundThemeGroup in group_ui_themes:
		group_ui_themes_dict[theme.group] = theme.theme
	
	group_ui_themes_dict[default_ui_theme_group] = default_ui_theme
	group_ui_themes_dict[no_ui_theme_group] = SoundTheme.new()
	
	var polyphonic: AudioStreamPolyphonic = AudioStreamPolyphonic.new()
	player.stream = polyphonic
	player.play()

func _enter_tree() -> void:
	Signals.safe_connect(self, get_tree().node_added, _on_node_added)
	
func _on_node_added(node: Node):
	if node is BaseButton:
		var theme: SoundTheme = _get_theme(node)
		if theme.button_down:
			Signals.safe_connect(self, node.button_down, _play.bind(node, theme.button_down))
		if theme.button_up:
			Signals.safe_connect(self, node.button_up, _play.bind(node, theme.button_up))
		if theme.button_hover:
			Signals.safe_connect(self, node.mouse_entered, _play.bind(node, theme.button_hover))

func _play(node: Node, stream: AudioStream):
	if node is BaseButton:
		if node.disabled:
			return
	
	var playback: AudioStreamPlaybackPolyphonic = player.get_stream_playback()
	playback.play_stream(stream)

func _get_theme(node: Node):
	var theme: SoundTheme = default_ui_theme
	
	var current_node: Node = node
	while current_node.get_parent() != null:
		for group: StringName in current_node.get_groups():
			if group_ui_themes_dict.has(group):
				theme = group_ui_themes_dict[group]
				
		current_node = current_node.get_parent()
	
	return theme
