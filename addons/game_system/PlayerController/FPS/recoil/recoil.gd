## Based on https://github.com/AceSpectre/GodotProceduralRecoil/blob/main/Recoil.gd
class_name Recoil
extends Node3D

# Rotations
var currentRotation : Vector3
var targetRotation : Vector3

# Recoil vectors
@export var recoilInfo: RecoilInfo

func _process(delta):
	# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, Vector3.ZERO, recoilInfo.returnSpeed * delta)
	currentRotation = lerp(currentRotation, targetRotation, recoilInfo.snappiness * delta)
	
	# Set rotation
	rotation = currentRotation
	
	# Camera z axis tilt fix, ignored if tilt intentional
	# I have no idea why it tilts if recoil.z is set to 0
	if recoilInfo.recoilVector.z == 0:
		global_rotation.z = 0

func recoilFire():
	targetRotation += Vector3(recoilInfo.recoilVector.x, randf_range(-recoilInfo.recoilVector.y, recoilInfo.recoilVector.y), randf_range(-recoilInfo.recoilVector.z, recoilInfo.recoilVector.z))
