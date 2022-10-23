extends Node2D

var initial_volume

func _ready():
	initial_volume = $AudioStreamPlayer.volume_db
func resume_background_music():
	$AudioStreamPlayer.playing = true
func stop_background_music():
	$AudioStreamPlayer.playing = false
