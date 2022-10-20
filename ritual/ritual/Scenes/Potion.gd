extends Area2D

class_name Potion

func pickup():
	$PickupSound.play()
	monitorable = false
	hide()
