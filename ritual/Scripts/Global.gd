extends Node

#player spawn

var debugging = true

func get_spawn():
	return get_node("/root/Main/PlayerSpawn")

func HUD_set_message(message):
	var label = get_node("/root/Main/HUD/Message")
	if label == null:
		push_error("Error")
		return
	label.show()
	label.text = message
		
func HUD_clear_message():
	var label = get_node("/root/Main/HUD/Message")
	if label == null:
		push_error("Error")
		return
	label.hide()
	
func HUD_set(name, amount):
	var label = get_node("/root/Main/HUD/VBoxContainer/"+name)
	if label == null:
		push_error("Error")
		return
	label.text = name + ": " + str(amount)

