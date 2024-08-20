## Based on https://github.com/AceSpectre/GodotProceduralRecoil/blob/main/Recoil.gd
class_name Recoil
extends Node3D

# Rotations
var currentRotation : Vector3
var targetRotation : Vector3

# Recoil vectors
@export var recoil : Vector3

# Settings
@export var snappiness : float
@export var returnSpeed : float

func _process(delta):
	# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, Vector3.ZERO, returnSpeed * delta)
	currentRotation = lerp(currentRotation, targetRotation, snappiness * delta)
	
	# Set rotation
	rotation = currentRotation
	
	# Camera z axis tilt fix, ignored if tilt intentional
	# I have no idea why it tilts if recoil.z is set to 0
	if recoil.z == 0:
		global_rotation.z = 0

func recoilFire():
	targetRotation += Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z))

func setRecoil(newRecoil : Vector3):
	recoil = newRecoil
