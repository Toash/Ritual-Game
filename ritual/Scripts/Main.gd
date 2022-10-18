extends Node2D

#export var lightColor = Color.white

#var lightsOff = false

func _ready():
	pass
	#Turn lights on
	#$World/CanvasModulate.color = lightColor
	#lightsOff = false

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		pass
		#flipLight()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		pass
		
"""
func flipLight():
	if lightsOff == false:
		lightsOff = true
		lightsOff()
	else:
		lightsOff = false
		lightsOn()

func lightsOn():
	$World/CanvasModulate.color = lightColor
	
func lightsOff():
	$World/CanvasModulate.color = Color.black
"""

