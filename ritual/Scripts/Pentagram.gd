extends Area2D

class_name Pentagram 

const MAX = 5
onready var TORCHES = [$TORCH1,$TORCH2,$TORCH3,$TORCH4,$TORCH5]
onready var amount = 0

func _ready():
	display(amount)
func _process(delta):
	pass

func place_torch():
	amount+=1
	display(amount)
	if amount==MAX:
		Global.win()
		pass

func display(amount):
	for i in range(len(TORCHES)):
		if i < amount:
			TORCHES[i].show()
		else:
			TORCHES[i].hide()
	



