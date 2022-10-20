extends KinematicBody2D

class_name Player

onready var torch = preload("res://Scenes/Environment/Torch.tscn")
onready var deathscreen = get_node("/root/Main/HUD/Deathscreen")
#public
export (int)var speed = 100
export (float)var sprintMulitplier = 3

#how long player can sprint
export (float) var energyMax = .7
export (float) var energyRegenRate = 2
export (float) var energyOverCooldown = 3
#minimum energy needed to sprint 
export (float) var energyThreshold = .3
export (int) var maxHealth = 1
export (float) var footStepInterval = .4

onready var bloodParticles = $Blood
onready var health = maxHealth
onready var torchCount = 0

#private
var vel = Vector2()

var sprinting:bool

#The current torch the player is next to
var currentTorch :Torch
var currentPentagram :Pentagram

var footstep_timer = 0
var energy = 0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	self.position = Global.get_player_spawn().position
	Global.HUD_clear_message()
	Global.HUD_set("Health",health)
	bloodParticles.emitting = false

func _process(delta):
	updateTimers(delta)
	if Input.is_action_just_pressed("interact"):
		if currentPentagram is Pentagram:
			self.placeTorchOnPentagram()
			return
		elif currentTorch is Torch:
			self.pickupTorch()
			return
		else:
			self.placeTorchOnGround()
			return
		
	movement()
	sprinting(delta)
	footsteps()
	animate()
	print(self.energy)
	
func pickupTorch():
	currentTorch.pickup()
	self.torchCount +=1
	
	Global.HUD_set("Torches",torchCount)
	pass
	
func placeTorchOnGround():
	if self.torchCount>0:
		print("placing torch")
		self.torchCount-=1
		Global.HUD_set("Torches",torchCount)
		var torch_instance = torch.instance()
		get_node("/root/Main").add_child(torch_instance)
		torch_instance.position = self.position

func placeTorchOnPentagram():
	if self.torchCount > 0:
		currentPentagram.place_torch()
		self.torchCount -= 1 
		Global.HUD_set("Torches",torchCount)
func takeDamage():
	health -= 1
	if health <= 1:
		bloodParticles.emitting = true
	else:
		bloodParticles.emitting = false
	if health == 0:
		die()
	Global.HUD_set("Health",health)

func die():
	#get_tree().reload_current_scene()
	deathscreen.show()
	get_tree().paused = true
	

func movement():
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
	
func sprinting(delta):
	if Input.is_action_pressed("sprint"):
		#sprint key pressed
		if energy>0:
			self.sprinting = true
			drainSprintEnergy(delta)
		#pressing key but no energy
		else:
			print("NOOO ENERGYYYY")
			self.sprinting = false
	#not pressing sprint key
	else:
		regainSprintEnergy(delta)
		self.sprinting = false
	
	
func footsteps():
	if vel.length() > 0:
		if self.footstep_timer>footStepInterval:
			playFootstep()
			
func playFootstep():
	var player = $Footstep
	player.pitch_scale = 1 + rng.randf_range(-0.2,0.2)
	player.play()
	resetFootstepTimer()

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
	if sprinting:
		move_and_slide(vel*sprintMulitplier*speed)
	else:
		move_and_slide(vel*speed)
	
func _entered_small_collider(area):
	if area is Torch:
		currentTorch = area
		Global.HUD_set_message("Pickup")
	if area is Pentagram:
		currentPentagram = area
		Global.HUD_set_message("Pentagram")
	if area is Potion:
		self.health +=1
		area.pickup()
		Global.HUD_set("Health",health)
		print("healed!")
	
func _exited_small_collider(area):
	if area is Torch:
		currentTorch = null 
		Global.HUD_clear_message()
	if area is Pentagram:
		currentPentagram = null
		Global.HUD_clear_message()
	
func _entered_spawn_collider(area):
	if area is GhostSpawn:
		area.deactivate()


func _exit_spawn_collider(area):
	if area is GhostSpawn:
		area.activate()

func updateTimers(delta):
	self.footstep_timer+=delta
	
func updateSprintTimer(delta):
	self.energy+=delta
	
func drainSprintEnergy(delta):
	self.energy -= delta
func regainSprintEnergy(delta):
	if energy >= energyMax: return
	self.energy += (delta*energyRegenRate)
func resetSprintTimer():
	self.energy=0
	
func resetFootstepTimer():
	self.footstep_timer=0

