extends TileMap


func _ready():
	if Global.debugging:
		show()
	else:
		hide()
