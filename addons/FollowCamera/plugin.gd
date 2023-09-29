extends EditorPlugin


func _enter_tree():
	add_custom_type("FixedFollowcamera", "Camera3D", preload("fixed_follow_camera.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("FixedFollowCamera")
