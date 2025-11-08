## Button that is disabled when player has no authority
class_name DisableUiNoAuthority
extends BaseButton

func _ready() -> void:
	disabled = not is_multiplayer_authority() and not Multiprocess.is_multiprocess_instance_running()
