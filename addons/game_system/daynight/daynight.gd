class_name Daynight extends Node

const tag : String = "Daynight"

@export var sun : DirectionalLight3D
@export var moon : DirectionalLight3D
## Time of sunrise. 0-1, 0 for 12am, 1 for 12am the next day
@export var sunrise : float
## Time of sunset. 0-1, 0 for 12am, 1 for 12am the next day
@export var sunset : float
## Color of the sun throughout the day (not night)
@export var sunlightGradient : Gradient

func _enter_tree():
	add_to_group(tag)

func _get_sun_location(time: float):
	# There is probably a super clever one liner here, but I can't brain
	if time > sunrise and time < sunset:
		return lerpf(0, 180, (time - sunrise) / (sunset - sunrise))
	elif time > sunset:
		return lerpf(180, 270, (time - sunset) / (1 - sunset))
	else:
		return lerpf(270, 360, time / sunrise)

## Move the sun. time is the time of day. 0 for 12am, 1 for 12am the next day
func move_sun(time : float):
	var sunLocation = _get_sun_location(time)
	
	var sun_rotation = sun.rotation_degrees
	sun_rotation.x = -sunLocation
	sun.rotation_degrees = sun_rotation
	
	# Moon is opposite the sun
	sun_rotation.x = -sunLocation - 180
	moon.rotation_degrees = sun_rotation

	sun.visible = sunLocation > 0 and sunLocation < 180
	moon.visible = !sun.visible

	if sun.visible:
		sun.light_color = _get_sun_color(time)
		
func _get_sun_color(time: float):
	return sunlightGradient.sample((time - sunrise) / (sunset - sunrise))
