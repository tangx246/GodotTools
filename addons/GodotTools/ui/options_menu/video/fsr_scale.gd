extends MenuOptionButton

@onready var scaling_mode_option: MenuOptionButton = %ScalingModeOption

const KEY: String = "FSR_Scale"

enum FSR_Scale {
	Ultra,
	Quality,
	Balanced,
	Performance
}

const FSR_Scale_Mapping: Dictionary[FSR_Scale, float] = {
	FSR_Scale.Ultra: 0.77,
	FSR_Scale.Quality: 0.67,
	FSR_Scale.Balanced: 0.59,
	FSR_Scale.Performance: 0.5
}

func _get_key() -> String:
	return KEY

func _get_current_setting() -> int:
	return PlayerPrefs.get_value(KEY, FSR_Scale.Ultra)

## Maps id to option
func _get_options() -> Dictionary[int, MenuOption]:
	return {
		FSR_Scale.Ultra: MenuOption.new(0, FSR_Scale.Ultra, "Ultra"),
		FSR_Scale.Quality: MenuOption.new(1, FSR_Scale.Quality, "Quality"),
		FSR_Scale.Balanced: MenuOption.new(2, FSR_Scale.Balanced, "Balanced"),
		FSR_Scale.Performance: MenuOption.new(3, FSR_Scale.Performance, "Performance")
	}

func _set_option(id: int):
	get_tree().root.get_viewport().scaling_3d_scale = FSR_Scale_Mapping[id]

func _enter_tree() -> void:
	_initialize.call_deferred()

func _initialize() -> void:
	scaling_mode_option.setting_changed.connect(_on_setting_changed)
	_on_setting_changed()

func _on_setting_changed() -> void:
	if get_tree().root.get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR or \
			get_tree().root.get_viewport().scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR2:
		super._enter_tree()

func _exit_tree() -> void:
	if scaling_mode_option.setting_changed.is_connected(_on_setting_changed):
		scaling_mode_option.setting_changed.disconnect(_on_setting_changed)
