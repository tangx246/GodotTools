extends RefCounted

@export var id: int
@export var name: String
@export var steam_id: String = "": # Stored as String as serialization in Godot seems to make it lose precision
	set(value):
		steam_id = value
		if value != "":
			fetch_avatar()
var avatar: Texture2D

signal updated

func fetch_avatar() -> void:
	var steam = SteamInit.get_steam()
	if steam and steam_id != "":
		var _on_persona_state_change = func(user_id: int, _flags: int) -> void:
			if user_id != int(steam_id):
				return

			if not steam.avatar_loaded.is_connected(_on_loaded_avatar):
				steam.avatar_loaded.connect(_on_loaded_avatar)
			steam.getPlayerAvatar(steam.AVATAR_SMALL, int(steam_id))

		if not steam.requestUserInformation(int(steam_id), false):
			_on_persona_state_change.call(int(steam_id), 0)
		else:
			if not steam.persona_state_change.is_connected(_on_persona_state_change):
				steam.persona_state_change.connect(_on_persona_state_change)

func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	if user_id != int(steam_id):
		return

	# Create the image and texture for loading
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	# Optionally resize the image if it is too large
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	avatar = avatar_texture

	updated.emit()

func _to_string() -> String:
	return Serializer.serialize(self)
	
static func deserialize(data: String, obj: Object = null):
	return Serializer.deserialize(data, obj)
