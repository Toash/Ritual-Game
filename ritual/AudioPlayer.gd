extends Node2D


func play_audio(clip):
	$AudioStreamPlayer.stream = clip
	$AudioStreamPlayer.play()
