extends KinematicBody2D

signal hit_player

class_name Ghost

export (float) var spawnCooldown = 8
export (int) var speed = 113
export (float) var sprintSpeedMultiplier = 2.05
export (float) var sprintCooldown = 5

onready var spawns = get_node("/root/Main/GhostSpawns").get_children()

onready var moan_1 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan01.wav")
onready var moan_2 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan02.wav")
onready var moan_3 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan03.wav")
onready var moan_4 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan04.wav")
onready var moan_5 = preload("res://Audio/Ghost/Moans/qubodup-GhostMoan05.wav")
var moans: Array

onready var agent = $NavigationAgent2D
onready var col = $Area2D/CollisionShape2D
onready var player = get_node("/root/Main/Player")
onready var los = $LineOfSight
onready var redLight = $RedLight

const LOOK_LIGHT_SPEED = 8
onready var lookingLight = $LookingLight

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

#shake when ghost has line of sight
const SPOT_SHAKE = 4
const SPOT_SHAKE_LENGTH = 1.5

#shake when ghost is close
const CLOSE_SHAKE = 1

func _ready():
	disappear()
	rng.randomize()
	moans = [moan_1,moan_2,moan_3,moan_4,moan_5]
	
func _process(delta):
	updateTimers(delta)
	spawning()
	if not manifested: return
	agent.set_target_location(player.position)
	lineOfSight()
	moans()
	redLight()
	rotate_looking_light_towards_walk_direction(delta)

	
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
			sprint_towards_player()
	else:
		seesPlayer = false
		redLight.hide()
		
func sprint_towards_player():
	redLight.show()
	seesPlayer = true
	closePlayer.play()
	player.get_node("Camera2D").shake(SPOT_SHAKE_LENGTH,SPOT_SHAKE)
	reset_sprint_timer()
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
	col.set_deferred("disabled",true)
	hide()
	manifested = false

	
func _on_Area2D_body_entered(body):
	if body is Player:
		attackPlayer(body)
		pass
	pass 
	
func attackPlayer(player):
	emit_signal("hit_player")
	attackPlayer.play()
	disappear()

func redLight():
	rotateRedLightTowardsPlayer()

func rotateRedLightTowardsPlayer():
	self.redLight.rotation=get_angle_to(player.position)-PI/2

func rotate_looking_light_towards_walk_direction(delta):
	self.lookingLight.rotation = lerp(lookingLight.rotation,get_angle_to(agent.get_next_location())-PI/2,delta*LOOK_LIGHT_SPEED)

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



