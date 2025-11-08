class_name MainMenu
extends Control

@export var game_loading_text: String = "Loading..."
var original_start_text: String

@onready var multiplayer_screen: Control = get_parent().get_node(^"%VBoxContainer")
@onready var clientui: Node = get_parent().get_node(^"%ClientUI")
@onready var multiplayer_back: Button = clientui.get_node(^"%Back")
@onready var options: Button = clientui.get_node(^"%Options")
@onready var start_new_game: Button = %NewSinglePlayerGame
@onready var multiplayer_button: Button = %Multiplayer
@onready var options_button: Button = %OptionsButton
@onready var exit_button: Button = %Exit
@onready var multiplayerUiRoot: Control = %Control

func _ready() -> void:
	Signals.safe_connect(self, visibility_changed, _on_visibility_changed)
	_on_visibility_changed()

	Signals.safe_connect(self, multiplayer_back.pressed, show)
	Signals.safe_connect(self, start_new_game.pressed, clientui.on_start_game_pressed)
	original_start_text = start_new_game.text
	Signals.safe_connect(self, Multiprocess.get_first_instance().server_creating, func():
		start_new_game.text = game_loading_text
	)
	Signals.safe_connect(self, multiplayer.connected_to_server, func(): 
		start_new_game.text = original_start_text
	)
	Signals.safe_connect(self, multiplayer_button.pressed, hide)
	Signals.safe_connect(self, options_button.pressed, options.pressed.emit)
	Signals.safe_connect(self, exit_button.pressed, get_tree().quit)

func _on_visibility_changed() -> void:
	multiplayer_screen.visible = not visible
