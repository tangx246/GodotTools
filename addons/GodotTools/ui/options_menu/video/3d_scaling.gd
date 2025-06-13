extends VBoxContainer

@onready var scaling_mode_option: MenuOptionButton = %ScalingModeOption
@onready var free_range_scale: Control = %FreeRangeScale
@onready var fsr_scale: Control = %FSRScale

func _enter_tree() -> void:
	_initialize.call_deferred()

func _initialize() -> void:
	scaling_mode_option.setting_changed.connect(_on_scaling_mode_changed)
	_on_scaling_mode_changed()

func _exit_tree() -> void:
	if scaling_mode_option.setting_changed.is_connected(_on_scaling_mode_changed):
		scaling_mode_option.setting_changed.disconnect(_on_scaling_mode_changed)

func _on_scaling_mode_changed():
	var viewport: Viewport = get_tree().root.get_viewport()
	if viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR or viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_FSR2:
		fsr_scale.visible = true
		free_range_scale.visible = false
	else:
		fsr_scale.visible = false
		free_range_scale.visible = true
	
