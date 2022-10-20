extends KinematicBody2D

signal hitPlayer

export (float) var spawnCooldown = 2
export (int) var speed = 65
export (float) var sprintSpeedMultiplier = 3
export (int) var appearTime = 10
export (float) var sprintCooldown = 4
export (float) var sight= 400

onready var spawns = get_node("/root/Main/GhostSpawns").get_children()

onready var moan_1 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan01.wav")
onready var moan_2 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan02.wav")
onready var moan_3 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan03.wav")
onready var moan_4 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan04.wav")
onready var moan_5 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan05.wav")
var moans: Array

onready var agent = $NavigationAgent2D
onready var col = $Area2D/CollisionShape2D
onready var player =  get_node("/root/Main/Player")
onready var los = $LineOfSight
onready var redLight = $RedLight

#sound 
onready var moanPlayer = $Moan
onready var closePlayer = $Close
onready var attackPlayer = $Attack

var seesPlayer: bool

var manifested

var vel = Vector2.ZERO

var moan_timer = 0
var sprint_timer = 0
var spawn_timer = 0

var rng = RandomNumberGenerator.new()

func _ready():
	disappear()
	rng.randomize()
	los.cast_to=Vector2(sight,0)
	moans = [moan_1,moan_2,moan_3,moan_4,moan_5]
	
func _process(delta):
	updateTimers(delta)
	spawning()
	if not manifested: return
	agent.set_target_location(player.position)
	lineOfSight()
	moans()
	redLight()

	
func _physics_process(delta):
	if not manifested: return
	if seesPlayer:
		move_and_slide(vel*sprintSpeedMultiplier*speed)
	else:
		move_and_slide(vel*speed)
	
func moans():
	if moanPlayer.playing: return
	var r = rng.randi_range(0,len(moans)-1)
	moanPlayer.stream = moans[r]
	moanPlayer.play()

	
func lineOfSight():
	vel = position.direction_to(agent.get_next_location())
	los.look_at(player.position)
	if los.get_collider() is Player:
		if sprint_timer > sprintCooldown:
			redLight.show()
			seesPlayer = true
			closePlayer.play()
			player.get_node("Camera2D").shake(.3,5)
			reset_sprint_timer()
	else:
		seesPlayer = false
		redLight.hide()
		
func spawning():
	if manifested: return
	if spawn_timer > spawnCooldown:
		var ghostSpawns = Global.get_active_ghostSpawns()
		if len(ghostSpawns)==0:
			print("ghost cannot spawn")
			return
		var r = rng.randi_range(0,len(ghostSpawns)-1)
		appear(ghostSpawns[r].position)

func dash():
	pass
	
func appear(pos):
	#spawns at predefined spawn points, if none are activated, return
	self.position = pos 
	var amountOfSpawns = len(spawns)
	
	attackPlayer.playing = false
	
	col.disabled = false
	show()
	manifested = true
	print("ghost spawned")
	
func disappear():
	reset_spawn_timer()
	moanPlayer.playing = false
	closePlayer.playing = false
	col.disabled = true
	hide()
	manifested = false

	
func _on_Area2D_body_entered(body):
	if body is Player:
		attackPlayer(body)
		pass
	pass 

func attackPlayer(player):
	attackPlayer.play()
	player.takeDamage()
	disappear()

func redLight():
	rotateRedLightTowardsPlayer()

func rotateRedLightTowardsPlayer():
	self.redLight.rotation=get_angle_to(player.position)-PI/2

func updateTimers(delta):
	self.moan_timer += delta 
	self.sprint_timer += delta
	self.spawn_timer += delta	
		
func reset_moan_timer():
	self.moan_timer = 0
func reset_sprint_timer():
	self.sprint_timer = 0
func reset_spawn_timer():
	self.spawn_timer = 0
