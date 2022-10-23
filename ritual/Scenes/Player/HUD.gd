extends CanvasLayer

class_name HUD

onready var tween = $Tween
onready var damage_screen = $DamageScreen

const BLEED_RATE = 1
const CLEAR_RATE = .6

var redness = 0

var bleeding: bool = false

func _process(delta):
	damage_screen.self_modulate= Color(1,1,1,redness)
	if bleeding:
		redness = clamp(redness + delta * BLEED_RATE,0,1)
		if redness >=1:
			bleeding = false
	else:
		redness = clamp(redness - delta * CLEAR_RATE,0,1)
	
func show_damage_screen():
	bleeding = true


func _on_ScreenBleed_timeout():
	pass
