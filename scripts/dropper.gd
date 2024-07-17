extends RigidBody2D

#Sprite Nodes
@onready var chasis_sprite = $ChasisSprite
@onready var mouth_sprite = $ChasisSprite/MouthSprite
@onready var legs = $ChasisSprite/Legs

#Ray Nodes
@onready var movement_stop_ray = $ChasisSprite/MovementStopRay
@onready var enemy_detection_ray = $ChasisSprite/EnemyDetectionRay

@onready var drop_point = $ChasisSprite/DropPoint

#Exported Var
@export var SPEED : int
@export var HEALTH : int
@export var STAGGER = false
@export_enum("left", "right") var facing = "right"
var DEAD = false
var SPAWNER

#Timers
@onready var wander_drop = $WanderDrop
@onready var follow_delay = $FollowDelay
@onready var follow_drop = $FollowDrop
@onready var cool_down = $CoolDown

#Scene Const
const SCRAPS = preload("res://scenes/scraps.tscn")

#Var
var direction = 1
enum actions {WANDER, PREPARING, FOLLOWING, COOLDOWN}
var state = actions.WANDER

var player
var target_location

# Called when the node enters the scene tree for the first time.
func _ready():
	if facing == "left":
		direction *= -1
		chasis_sprite.scale.x *= -1
	enter_wander()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if DEAD == true:
		SPAWNER.enemy_dead = true
		queue_free()
	
	if not STAGGER:
		match state:
			actions.WANDER:
				if  linear_velocity.x == 0 or movement_stop_ray.is_colliding():
					direction *= -1
					chasis_sprite.scale.x *= -1
					linear_velocity.x = direction * SPEED
				elif enemy_detection_ray.is_colliding():
					if enemy_detection_ray.get_collider().name == 'Player':
						player = enemy_detection_ray.get_collider()
						enter_preparing()
						follow_delay.start()
				
				if mouth_sprite.frame == 3:
					drop_projectile()
					mouth_sprite.play_backwards("default")
				pass
				
			actions.PREPARING:
				pass
				
			actions.FOLLOWING:
				#if direction == 1 and position.x > target_location.x or direction == -1 and position.x < target_location.x:
					#linear_velocity.x = move_toward(linear_velocity.x, 0, (SPEED*2)*delta)
					
				if  linear_velocity.x == 0 or movement_stop_ray.is_colliding():
					enter_cooldown()
					cool_down.start()
				pass
				
			actions.COOLDOWN:
				pass
	else:
		match state:
			actions.WANDER:
				wander_drop.paused = true
				pass
			actions.PREPARING:
				follow_delay.paused = true
				pass
			actions.FOLLOWING:
				follow_drop.paused = true
				pass
			actions.COOLDOWN:
				cool_down.paused = true
				pass
		linear_velocity.x = 0
		mouth_sprite.pause()
		for leg in legs.get_children():
			leg.pause()
			
func enter_wander():
	wander_drop.start()
	linear_velocity.x = direction * SPEED
	for leg in legs.get_children():
		leg.play()
	chasis_sprite.play("default")
	state = actions.WANDER

func enter_preparing():
	wander_drop.stop()
	linear_velocity.x = 0
	mouth_sprite.play("default")
	for leg in legs.get_children():
		leg.pause()
	chasis_sprite.play("attack")
	state = actions.PREPARING

func enter_following(inital):
	for leg in legs.get_children():
		leg.play("default")
	if inital:
		target_location = player.global_position
		if target_location.x > global_position.x:
			direction = 1
			chasis_sprite.scale.x = 1
		elif target_location.x < global_position.x:
			direction = -1
			chasis_sprite.scale.x = -1
	linear_velocity.x = direction * SPEED * 2
	
	
	follow_drop.start()
	drop_projectile()
	state = actions.FOLLOWING
	
func enter_cooldown():
	follow_drop.stop()
	mouth_sprite.play_backwards("default")
	for leg in legs.get_children():
		leg.pause()
	state = actions.COOLDOWN

func open_mouth():
	mouth_sprite.play("default")

func drop_projectile():
	var s = SCRAPS.instantiate()
	s.global_position = drop_point.global_position
	get_parent().add_child(s)

func exit_stagger():
	match state:
		actions.WANDER:
			enter_wander()
			wander_drop.paused = false
			pass
		actions.PREPARING:
			enter_preparing()
			follow_delay.paused = false
			pass
		actions.FOLLOWING:
			enter_following(false)
			follow_drop.paused = false
			pass
		actions.COOLDOWN:
			enter_cooldown()
			cool_down.paused = false
			pass
