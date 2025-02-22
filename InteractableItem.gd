extends Node3D
class_name InteractableItem

@export var hilightMesh: MeshInstance3D

func Focus():
	hilightMesh.visible = true
	
func UnFocus():
	hilightMesh.visible = false
	
	
