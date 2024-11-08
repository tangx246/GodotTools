class_name RecoilInfo
extends Resource

@export var recoilVector: Vector3 = Vector3(0.5, 0.1, 0)
## How quickly it snaps towards the target recoil vector
@export var snappiness: float = 10
## How quickly we return towards neutral
@export var returnSpeed: float = 10
