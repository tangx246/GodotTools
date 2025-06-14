extends KeyValueStore

func _init() -> void:
	savePath = "user://playerprefs.save"

	super(savePath)
