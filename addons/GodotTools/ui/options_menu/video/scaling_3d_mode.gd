extends MenuOptionButton

const KEY: String = "Scaling3DMode"

func _get_key() -> String:
	return KEY

func _get_current_setting() -> int:
	return get_tree().root.get_viewport().scaling_3d_mode

## Maps id to option
func _get_options() -> Dictionary[int, MenuOption]:
	return {
		Viewport.SCALING_3D_MODE_BILINEAR: MenuOption.new(0, Viewport.SCALING_3D_MODE_BILINEAR, "Bilinear"),
		Viewport.SCALING_3D_MODE_FSR: MenuOption.new(1, Viewport.SCALING_3D_MODE_FSR, "AMD FidelityFX Super Resolution 1.0"),
		Viewport.SCALING_3D_MODE_FSR2: MenuOption.new(2, Viewport.SCALING_3D_MODE_FSR2, "AMD FidelityFX Super Resolution 2.2")
	}

func _set_option(id: int):
	get_tree().root.get_viewport().scaling_3d_mode = id
