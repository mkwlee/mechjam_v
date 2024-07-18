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

@onready var prepare_sfx = $PrepareSFX
@onready var charge_sfx = $ChargeSFX
@onready var cool_down_sfx = $CoolDownSFX
@onready var wall_hit_sfx = $WallHitSFX
@onready var death_sfx = $DeathSFX


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
		linear_velocity = Vector2(0, 0)
		spike.ACTIVE = false
		chasis_sprite.hide()
		if not death_sfx.playing:
			death_sfx.play()
	
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
				if linear_velocity.x == 0 or movement_stop_ray.is_colliding():
					wall_hit_sfx.play()
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
	if not prepare_sfx.playing:
		prepare_sfx.play()
	linear_velocity.x = 0
	chasis_sprite.play("attack")
	fire_sprite.hide()
	spike_sprite.play("default")
	state = actions.PREPARING

func enter_charging():
	if not charge_sfx.playing:
		charge_sfx.play()
	linear_velocity.x = direction * SPEED * 2
	spike.ACTIVE = true
	fire_sprite.play("charging")
	fire_sprite.show()
	state = actions.CHARGING

func enter_cooldown():
	charge_sfx.stop()
	if not cool_down_sfx.playing:
		cool_down_sfx.play()
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
	
			

func _on_death_sfx_finished():
	SPAWNER.enemy_dead = true
	queue_free()
