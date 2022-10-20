extends CanvasModulate


func _ready():
	if Global.debugging: 
		color = Color(.5,.5,.5,1)
	else:
		color = Color(0,0,0,1)
