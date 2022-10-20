extends Node2D

class_name GhostSpawn

onready var activated:bool = true

onready var onGizmo = $Activated
onready var offGizmo = $Deactivated

func _ready():
	if Global.debugging:
		onGizmo.show()
		offGizmo.show()
	else:
		onGizmo.hide()
		offGizmo.hide()

func activate():
	if Global.debugging:
		onGizmo.show()
		offGizmo.hide()
	activated = true
	
	
func deactivate():
	if Global.debugging:
		onGizmo.hide()
		offGizmo.show()
	activated = false
