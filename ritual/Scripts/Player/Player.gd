extends KinematicBody2D

class_name Player

onready var torch = preload("res://Scenes/Environment/Torch.tscn")
onready var hud:HUD= get_node("/root/Main/HUD")
#public
export (int)var speed = 125
export (float)var sprintMulitplier = 3

#how long player can sprint
export (float) var energyMax = 100
export (float) var energyDepleteRate = 100
export (float) var energy_regen_delay = 2.3
#minimum energy needed to sprint 
export (int) var maxHealth = 2
export (float) var walkingFootStepInterval = .4
export (float) var sprintingFootStepInterval = .2
export (Color) var damage_color = Color(.5,.2,.2,1)

onready var bloodParticles = $Blood
onready var health = maxHealth
onready var torchCount = 0
onready var ghost = get_node("/root/Main/Ghost")

onready var default_color = $AnimatedSprite.self_modulate

#private
var vel = Vector2()

var sprinting:bool
var sprintReleased: bool = false

#The current torch the player is next to
var currentTorch :Torch
var currentPentagram :Pentagram
var in_pentagram : bool

var out_of_breath_timer = 100
var footstep_timer = 0
var energy = 0
var currentFootstepInterval = 0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	self.position = Global.get_player_spawn().position
	Global.HUD_clear_message()
	Global.HUD_set("Health",health)
	Global.HUD_set("Torches",torchCount)
	bloodParticles.emitting = false
	ghost.connect("hit_player",self,"ghost_hit_player")
	energy = energyMax

func ghost_hit_player():
	$Camera2D.shake(2,20)
	takeDamage(1)
	pass

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
			#self.placeTorchOnGround()
			return
	movement()
	sprinting(delta)
	footsteps()
	animate()
	print("Energy : "+str(self.energy))
	
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
		Global.HUD_set_message(str(currentPentagram.MAX-currentPentagram.amount) + " torches left")
func takeDamage(damage):
	health -= damage
	if damage>0:
		hud.show_damage_screen()
	if health <= 1:
		bloodParticles.emitting = true
		$AnimatedSprite.self_modulate = damage_color
	else:
		bloodParticles.emitting = false
		$AnimatedSprite.self_modulate = default_color
	if health == 0:
		die()
	Global.HUD_set("Health",health)

func die():
	get_tree().change_scene("res://Scenes/Player/PlayerDeathAnimation.tscn")
	

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
	if energy <= 0 and out_of_breath_timer > energy_regen_delay:
		#want to play out of breath when no energy and timer hasnet started yet
		$OutOfBreath.play()
		out_of_breath_timer=0
	if Input.is_action_pressed("sprint") and energy > 0 :
		#sprinting before cooldown timer timeout
		if sprintReleased:
			# stop the regen
			start_sprint_cooldown_timer()
			sprintReleased = false
		self.sprinting = true
		drainSprintEnergy(delta)
	#not pressing sprint key
	elif Input.is_action_just_released("sprint") or energy <= 0:
		# start regen energy
		# If timer hasnt started yet 
		if $SprintCooldown.time_left == 0:
			start_sprint_cooldown_timer()
		sprintReleased = true
		self.sprinting = false

		
func start_sprint_cooldown_timer():
	$SprintCooldown.wait_time = energy_regen_delay
	$SprintCooldown.start()
	
#only want to execute this when the player isnt sprinting nor releasing that key	
#sprint cooldown over should execute when energy is 0 or player releases key
#if player sprints while timer count down, reset timer
func _sprint_cooldown_over():
	sprintReleased = false
	energy = energyMax
	
func footsteps():
	if vel.length() > 0:
		if sprinting:
			if footstep_timer>sprintingFootStepInterval:
				playFootstep()
		elif footstep_timer>walkingFootStepInterval:
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
		Global.HUD_set_message(str(currentPentagram.MAX-currentPentagram.amount) + " torches left")
	if area is Potion:
		takeDamage(-1)
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
	self.out_of_breath_timer += delta
	
func updateSprintTimer(delta):
	self.energy+=delta
	
func drainSprintEnergy(delta):
	self.energy -= delta*energyDepleteRate
	
func resetSprintTimer():
	self.energy=0
	
func resetFootstepTimer():
	self.footstep_timer=0

