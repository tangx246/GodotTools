extends Button

func _ready() -> void:
	pressed.connect(MultiplayerSceneSwitcher.back_to_main.bind(self))
