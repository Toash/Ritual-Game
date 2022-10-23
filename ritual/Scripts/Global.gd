extends Node

#player spawn

var debugging = false
	

func win():
	get_tree().change_scene("res://Scenes/WinCutscene.tscn")
	pass

func display_start_message(time):
	var message : StartMessage = get_node("/root/Main/HUD/StartMessage")
	message.display_start_message()

func get_player_spawn():
	return get_node("/root/Main/PlayerSpawn")


func get_active_ghostSpawns():
	var spawns = get_node("/root/Main/GhostSpawns").get_children()
	var activeSpawns = Array()
	for spawn in spawns:
		if spawn.activated:
			activeSpawns.append(spawn)
	return activeSpawns
	


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
	var label:Label = get_node("/root/Main/HUD/VBoxContainer/"+name)
	if label == null:
		push_error("Error")
		return
	label.text = name + ": " + str(amount)

