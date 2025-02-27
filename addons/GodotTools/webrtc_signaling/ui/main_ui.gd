extends Control

func _enter_tree() -> void:
	pass
	#for c in $VBoxContainer/Clients.get_children():
		## So each child gets its own separate MultiplayerAPI.
		#get_tree().set_multiplayer(
				#MultiplayerAPI.create_default_interface(),
				#NodePath("%s/VBoxContainer/Clients/%s" % [get_path(), c.name])
		#)


func _ready() -> void:
	if OS.get_name() == "Web":
		$VBoxContainer/Signaling.hide()
	if OS.has_feature("dedicated_server") or DisplayServer.get_name() == "headless":
		_on_listen_toggled(true)


func _on_listen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$Server.listen(int($VBoxContainer/Signaling/Port.value))
	else:
		$Server.stop()
