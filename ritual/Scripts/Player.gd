extends KinematicBody2D

signal scare100

#public
export (int)var speed = 400
export (int)var startingHealth = 3

#private
var scaredMeter
var vel = Vector2()
onready var currentHealth = startingHealth

onready var torchCount = 0

#The current torch the player is next to
var currentTorch 

func _ready():
	self.position = Global.get_spawn().position
	Global.clear_message()
	pass

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if currentTorch != null:
			if currentTorch.has_method("pickup"):
				currentTorch.pickup()
				torchCount +=1
	movement(delta)
	animate()
	
func pickupTorch():
	pass
	
func placeTorch():
	pass
func takeDamage():
	currentHealth -= 1
	
	if currentHealth == 0:
		get_tree().reload_current_scene()

func movement(delta):
	vel = Vector2.ZERO
	if Input.is_action_pressed("up"):
		vel.y -= 1
	if Input.is_action_pressed("down"):
		vel.y +=1
	if Input.is_action_pressed("right"):
		vel.x  +=1
	if Input.is_action_pressed("left"):
		vel.x -=1
	vel = vel.normalized()
	
func animate():
	var k = $AnimatedSprite
	if vel.length() == 0:
		#check what prev animation was playing
		match k.animation:
			"down":
				k.animation = "idle_d"
				return
			"up":
				k.animation = "idle_u"
				return
			"right":
				k.animation = "idle_r"
				return
			"left":
				k.animation = "idle_l"
				return
	if vel.y>0:
		k.animation = "down"
		return
	elif vel.y<0:
		k.animation = "up"
		return
	if vel.x>0:
		k.animation = "right"
		return
	elif vel.x<0:
		k.animation = "left"
		return
	
		
func _physics_process(delta):
	move_and_slide(vel*speed)
	


func _entered_torch_collider(area):
	if area is Torch:
		print("touching torch")
		Global.set_message("Pickup")
		currentTorch = area
		
		
func _exited_torch_collider(area):
	if area is Torch:
		currentTorch = null 
		Global.clear_message()
		currentTorch = null
	
func _entered_spawn_collider(area):
	if area is GhostSpawn:
		area.activate()


func _exit_spawn_collider(area):
	if area is GhostSpawn:
		area.deactivate()



