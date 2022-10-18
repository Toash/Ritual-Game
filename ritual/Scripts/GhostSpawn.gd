extends Node2D

class_name GhostSpawn

onready var activated:bool = false

onready var onGizmo = $Activated
onready var offGizmo = $Deactivated

func activate():
	if Global.debugging == true:
		onGizmo.show()
		offGizmo.hide()
	activated = true
	print("Activated")
	pass
	
	
func deactivate():
	if Global.debugging == true:
		onGizmo.hide()
		offGizmo.show()
	activated = false
	print("Deactivated")
	pass
