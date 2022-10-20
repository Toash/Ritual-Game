extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
		pass
	


