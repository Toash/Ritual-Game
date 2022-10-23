extends Label

class_name StartMessage

func display_start_message():
	$Tween.interpolate_property(self, "percent_visible",0,1,2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()
	$Timer.start()
	


func _on_Timer_timeout():
	hide()
