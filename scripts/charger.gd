extends RigidBody2D

# Node references
@onready var chasis_sprite = $ChasisSprite
@onready var fire_sprite = $ChasisSprite/FireSprite
@onready var spike_sprite = $ChasisSprite/SpikeSprite

@onready var movement_stop_ray = $ChasisSprite/MovementStopRay
@onready var enemy_detection_ray = $ChasisSprite/EnemyDetectionRay

@onready var charge_delay = $ChargeDelay
@onready var cool_down = $CoolDown

@onready var spike = $ChasisSprite/Spike


@export var SPEED : int
@export var HEALTH : int
@export var STAGGER = false
@export_enum("left", "right") var facing = "right"
var DEAD = false
var SPAWNER

var direction = 1
enum actions {WANDER, PREPARING, CHARGING, COOLDOWN}
var state = actions.WANDER


var target_location
var air
var ground


# Called when the node enters the scene tree for the first time.
func _ready():
	if facing == "left":
		direction *= -1
		chasis_sprite.scale.x *= -1
	enter_wander()
	
	ground = position.y
	air = position.y - 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if DEAD == true:
		SPAWNER.enemy_dead = true
		queue_free()
	
	if not STAGGER:
		match state:
			actions.WANDER:
				if linear_velocity.x == 0 or movement_stop_ray.is_colliding():
					direction *= -1
					chasis_sprite.scale.x *= -1
					linear_velocity.x = direction * SPEED
				elif enemy_detection_ray.is_colliding():
					if enemy_detection_ray.get_collider().name == 'Player':
						enter_preparing()
						charge_delay.start()
						
			actions.PREPARING:
				position.y = move_toward(position.y, air, (16 / charge_delay.wait_time)*delta)
				
			actions.CHARGING:
				#if direction == 1 and position.x > target_location.x or direction == -1 and position.x < target_location.x:
					#fire_sprite.play("default")
					#linear_velocity.x = move_toward(linear_velocity.x, 0, (SPEED*2)*delta)
					
				if linear_velocity.x == 0 or movement_stop_ray.is_colliding():
					enter_cooldown()
					cool_down.start()
					
			actions.COOLDOWN:
				position.y = move_toward(position.y, ground, (16 / cool_down.wait_time)*delta)
	else:
		match state:
			actions.PREPARING:
				charge_delay.paused = true
			actions.COOLDOWN:
				cool_down.paused = true
		linear_velocity.x = 0
		spike_sprite.pause()
		fire_sprite.pause()
			
func enter_wander():
	linear_velocity.x = direction * SPEED
	spike.ACTIVE = false
	chasis_sprite.play("default")
	fire_sprite.play("default")
	fire_sprite.show()
	state = actions.WANDER

func enter_preparing():
	#target_location = enemy_detection_ray.get_collision_point()
	linear_velocity.x = 0
	chasis_sprite.play("attack")
	fire_sprite.hide()
	spike_sprite.play("default")
	state = actions.PREPARING

func enter_charging():
	linear_velocity.x = direction * SPEED * 2
	spike.ACTIVE = true
	fire_sprite.play("charging")
	fire_sprite.show()
	state = actions.CHARGING

func enter_cooldown():
	fire_sprite.hide()
	spike_sprite.play_backwards("default")
	state = actions.COOLDOWN

func exit_stagger():
	match state:
		actions.WANDER:
			enter_wander()
			pass
		actions.PREPARING:
			enter_preparing()
			charge_delay.paused = false
			pass
		actions.CHARGING:
			enter_charging()
			pass
		actions.COOLDOWN:
			enter_cooldown()
			cool_down.paused = false
			pass
	
			
