extends Node

#player spawn

var debugging = true


	
func get_spawn():
	return get_node("/root/Main/PlayerSpawn")



func set_message(message):
	var label = get_node("/root/Main/HUD/Message")
	label.show()
	label.text = message
		
func clear_message():
	var label = get_node("/root/Main/HUD/Message")
	label.hide()
	


