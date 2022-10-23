extends Area2D

class_name Potion

func pickup():
	$PickupSound.play()
	$CollisionShape2D.set_deferred("disabled",true)
	hide()
