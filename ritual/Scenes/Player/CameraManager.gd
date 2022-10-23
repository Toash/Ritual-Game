extends Camera2D

#Handles camera shaking
class_name CameraManager

var shake_amount = 0
onready var default_offset = self.offset

onready var tween = $Tween
onready var timer = $Timer

const RETURN_TIME = 3

func _ready():
	set_process(false)
	randomize()

func _process(delta):
	#camera shake is dependant on framerate uh oh!!
	self.offset = Vector2(rand_range(-1,1)*shake_amount,rand_range(-1,1)*shake_amount)

func shake(time, amount):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()
	
func _on_Timer_timeout():
	set_process(false)
	tween.interpolate_property(self, "offset",offset,default_offset,RETURN_TIME,9,2)

