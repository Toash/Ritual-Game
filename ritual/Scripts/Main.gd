extends Node2D

func _ready():
	BackgroundMusic.get_child(0).volume_db = -28
	BackgroundMusic.resume_background_music()
	Global.display_start_message(4)
	



