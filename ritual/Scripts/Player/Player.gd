extends KinematicBody2D

#public
export (int)var speed = 400
export (int)var startingHealth = 3
export (float) var footStepInterval = .4

#private
var vel = Vector2()

onready var health = startingHealth

onready var torchCount = 0

#The current torch the player is next to
var currentTorch 
var currentPentagram

var timer = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	self.position = Global.get_spawn().position
	Global.HUD_clear_message()
	pass

func _process(delta):
	updateTimer(delta)
	if Input.is_action_just_pressed("interact"):
		if currentTorch != null:
			if currentTorch.has_method("pickup"):
				pickupTorch()
	
	movement(delta)
	footsteps()
	animate()
	
func pickupTorch():
	currentTorch.pickup()
	torchCount +=1
	Global.HUD_set("Torches",torchCount)
	pass
	
func placeTorch():
	pass
func takeDamage():
	health -= 1
	
	if health == 0:
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
	
func footsteps():
	if vel.length() > 0:
		if self.timer>footStepInterval:
			playFootstep()
			
func playFootstep():
	var player = $Footstep
	player.pitch_scale = 1 + rng.randf_range(-0.2,0.2)
	player.play()
	resetTimer()

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
	
func _entered_small_collider(area):
	if area is Torch:
		currentTorch = area
		Global.HUD_set_message("Pickup")
	if area is Pentagram:
		currentPentagram = area
		Global.HUD_set_message("Pentagram")
		pass
	
func _exited_small_collider(area):
	if area is Torch:
		currentTorch = null 
		Global.HUD_clear_message()
	if area is Pentagram:
		currentPentagram = null
		Global.HUD_clear_message()
	
func _entered_spawn_collider(area):
	if area is GhostSpawn:
		area.activate()


func _exit_spawn_collider(area):
	if area is GhostSpawn:
		area.deactivate()

func updateTimer(delta):
	self.timer+=delta
func resetTimer():
	self.timer=0

