extends Node2D

func _ready():
	BackgroundMusic.stop_background_music()

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().change_scene("res://Scenes/Menu/Main.tscn")

