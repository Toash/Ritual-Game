extends KinematicBody2D

signal hitPlayer



export (int) var speed = 200
export (int) var appearTime = 10
export (float) var sight= 200

export var spawns = []


onready var agent = $NavigationAgent2D
onready var col = $Area2D/CollisionShape2D
onready var player =  get_node("/root/Main/Player")
onready var los = $LineOfSight


var manifested

var vel = Vector2.ZERO

func _ready():
	appear()
	los.cast_to=Vector2(sight,0)


func _process(delta):
	if not manifested: return
	agent.set_target_location(player.position)
	vel = position.direction_to(agent.get_next_location())
	pass
	
func _physics_process(delta):
	if not manifested: return
	move_and_slide(vel*speed)
	pass
	
	
func rotate_los_towards_player():
	pass

func dash():
	pass
	
func appear():
	#spawns at predefined spawn points, if none are activated, return
	var amountOfSpawns = len(spawns)
	
	
		
	col.disabled = false
	show()
	manifested = true
	pass
	
func disappear():
	col.disabled = true
	hide()
	manifested = false
	pass
	
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		print("Hit player!")
		disappear()
		pass
	pass 
