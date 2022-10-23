extends Area2D

class_name Torch

var audio = preload("res://Audio/foom_0.wav")

func _ready():
	pass # Replace with function body.
	
func pickup():
	AudioPlayer.play_audio(audio)
	self.queue_free()
	

