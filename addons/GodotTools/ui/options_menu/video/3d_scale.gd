extends MenuApplyHSlider

@onready var scaling_mode_option: MenuOptionButton = %ScalingModeOption

signal text_changed(val: String)

const SCALE_3D_KEY = "3d_scale"

func _get_key() -> String:
	return SCALE_3D_KEY

func _apply_setting(value: float) -> void:
	get_tree().root.get_viewport().scaling_3d_scale = value

func _enter_tree() -> void:
	_initialize.call_deferred()

func _initialize() -> void:
	scaling_mode_option.setting_changed.connect(_on_setting_changed)
	_on_setting_changed()

func _on_setting_changed() -> void:
	if get_tree().root.get_viewport().scaling_3d_mode != Viewport.SCALING_3D_MODE_FSR and \
			get_tree().root.get_viewport().scaling_3d_mode != Viewport.SCALING_3D_MODE_FSR2:
		super._enter_tree()

func _exit_tree() -> void:
	if scaling_mode_option.setting_changed.is_connected(_on_setting_changed):
		scaling_mode_option.setting_changed.disconnect(_on_setting_changed)
