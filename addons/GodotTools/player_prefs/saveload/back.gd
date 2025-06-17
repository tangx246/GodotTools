extends Button

func _ready() -> void:
	pressed.connect(get_window().hide)
