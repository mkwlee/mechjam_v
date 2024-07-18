extends CharacterBody2D

#Node References
@onready var back_leg_sprite : AnimatedSprite2D = $ChasisSprite/BackLegSprite
@onready var chasis_sprite : AnimatedSprite2D = $ChasisSprite
@onready var front_leg_sprite : AnimatedSprite2D = $ChasisSprite/FrontLegSprite

@onready var gun_sprite : AnimatedSprite2D = $ChasisSprite/GunSprite
@onready var gun_tip : Marker2D = $ChasisSprite/GunSprite/GunTip


@onready var charge_sprite : AnimatedSprite2D = $ChasisSprite/ChargeSprite
@onready var charge_tip : Marker2D = $ChasisSprite/ChargeSprite/ChargeTip
@onready var ball_sprite : Sprite2D = $ChasisSprite/ChargeSprite/BallSprite


@onready var thrower_sprite : AnimatedSprite2D = $ChasisSprite/ThrowerSprite
@onready var thrower_tip : Marker2D = $ChasisSprite/ThrowerSprite/ThrowerTip
@onready var fire_sprite : AnimatedSprite2D = $ChasisSprite/ThrowerSprite/FireSprite
@onready var fire_ray_cast : RayCast2D = $ChasisSprite/ThrowerSprite/FireRayCast
@onready var fire_detection : Area2D = $ChasisSprite/ThrowerSprite/Fire

@onready var explosion_sprite = $ExplosionSprite

@onready var arms = [[gun_sprite, gun_tip], [charge_sprite, charge_tip], [thrower_sprite, thrower_tip]]

#Scene references
const BULLET : PackedScene = preload("res://scenes/bullet.tscn")
const BALL : PackedScene = preload("res://scenes/ball.tscn")

@export var SPEED : int
@export var JUMP : int

#Timer References
@onready var gun_cool_down : Timer = $Timers/GunCoolDown
@onready var charge_power_up : Timer = $Timers/ChargePowerUp
@onready var damage_immunity : Timer = $Timers/DamageImmunity


#SFX
@onready var gun_shoot_sfx = $GunShoot
@onready var charge_hold_sfx = $ChargeHold
@onready var fire_shoot_sfx = $FireShoot
@onready var jump_sfx = $Jump
@onready var hurt_sfx = $Hurt
@onready var charge_shoot = $ChargeShoot
@onready var death = $Death



@export var GUN_COOLDOWN : float
@export var CHARGE_POWERUP : float
@export var DAMAGE_IMMUNITY : float

@onready var health_bar = GUI.health_bar


var current_arm : int = 0
var current_direction : int = 1
var player_dead = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	set_timers()
	
func _physics_process(delta):
	if GameManager.dead and not player_dead:
		player_death()
	
	
	# Add the gravity.
	if not is_on_floor() and not player_dead:
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
		
	if direction != 0 and not player_dead:
		
		if current_direction != direction:
			current_direction = direction
			chasis_sprite.scale.x *= -1
		
		velocity.x = direction * SPEED
		if is_on_floor():
			back_leg_sprite.play("walk")
			front_leg_sprite.play("walk")
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
			back_leg_sprite.play("idle")
			front_leg_sprite.play("idle")
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not player_dead:
		velocity.y = -JUMP
		jump_sfx.play()
		back_leg_sprite.play("jump")
		front_leg_sprite.play("jump")

	move_and_slide()
	rotate_arm_up()
	if not player_dead:
		shoot_gun()
	#
		
	if Input.is_action_just_pressed("switch_arm") and not player_dead:
		switch_arm(-1)

func flipped_player(state):
	chasis_sprite.flip_h = state
	
	back_leg_sprite.flip_h = state
	back_leg_sprite.position.x *= -1
	back_leg_sprite.offset.x *= -1
	
	for a in arms:
		a[0].flip_h = state
		a[0].position.x *= -1
		a[0].offset.x *= -1
		a[1].position.x *= -1
	
	fire_sprite.flip_h = state
	fire_sprite.position.x *= -1
	fire_sprite.offset.x *= -1
	
	fire_ray_cast.target_position.x *= -1
	
	front_leg_sprite.flip_h = state
	front_leg_sprite.position.x *= -1
	front_leg_sprite.offset.x *= -1

func rotate_arm_up():
	if Input.is_action_pressed("up"):
		for a in arms:
			a[0].rotation_degrees = -90
	else:
		for a in arms:
			a[0].rotation_degrees = 0

func shoot_gun():
	match current_arm:
		0: #Gun
			if gun_cool_down.is_stopped():
				if Input.is_action_pressed("shoot"):
					var b = BULLET.instantiate()
					b.rotation = gun_tip.global_rotation
					b.direction = current_direction
					b.position = gun_tip.global_position
					get_tree().current_scene.add_child(b)
					gun_sprite.play("shoot")
					gun_shoot_sfx.play()
					gun_cool_down.start()
			pass
		1: #Charge
			if Input.is_action_just_pressed("shoot"): #Start of charge
				ball_sprite.position = charge_tip.position
				ball_sprite.scale = Vector2(0.5, 0.5)
				ball_sprite.show()
				charge_hold_sfx.pitch_scale = 0.5
				charge_shoot.pitch_scale = 0.5
				charge_hold_sfx.play()
				charge_power_up.start()
			elif Input.is_action_pressed("shoot"): #During charge
				ball_sprite.position = charge_tip.position
				var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
				ball_sprite.scale = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
				ball_sprite.rotate(PI/2)
				charge_hold_sfx.pitch_scale = abs(time_held*0.5)
			elif Input.is_action_just_released("shoot"): #Release charge
				if ball_sprite.visible == true:
					var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
					var b = BALL.instantiate()
					b.rotation = charge_tip.global_rotation
					b.direction = current_direction
					b.position = charge_tip.global_position
					b.damage_multiplier = pow(10, time_held)
					b.speed_multiplier = time_held+1
					b.size = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
					ball_sprite.hide()
					charge_sprite.play("shoot")
					charge_hold_sfx.stop()
					charge_shoot.pitch_scale = time_held*0.5
					charge_shoot.play()
					get_tree().current_scene.add_child(b)
			pass
		2: #Thrower
			if Input.is_action_pressed("shoot"):
				fire_detection.collision_shape.disabled = false
				fire_ray_cast.enabled = true
				if fire_ray_cast.is_colliding():
					var ray_size = thrower_tip.global_position.distance_to(fire_ray_cast.get_collision_point())
					fire_sprite.scale.x = ray_size/96
					fire_detection.scale.x = ray_size/96
				else:
					fire_sprite.scale.x = 1
					fire_detection.scale.x = 1
				
				fire_sprite.show()
				fire_sprite.play("fire")
				if not fire_shoot_sfx.playing:
					fire_shoot_sfx.play()
			else:
				fire_detection.collision_shape.disabled = true
				fire_ray_cast.enabled = false
				fire_sprite.scale.x = 1
				fire_detection.scale.x = 1
				fire_sprite.hide()
				fire_shoot_sfx.stop()

func set_timers():
	gun_cool_down.wait_time = GUN_COOLDOWN
	gun_cool_down.one_shot = true
	charge_power_up.wait_time = CHARGE_POWERUP
	charge_power_up.one_shot = true
	damage_immunity.wait_time = DAMAGE_IMMUNITY
	damage_immunity.one_shot = true

func switch_arm(specific_arm):
	if specific_arm < 0:
		current_arm = (current_arm + 1) % 3
		while not GameManager.unlocked_arms[current_arm]:
			current_arm = (current_arm + 1) % 3
	else:
		current_arm = specific_arm
		
	for a in 3:
		if a == current_arm:
			arms[a][0].show()
			arms[a][1].show()
		else:
			arms[a][0].hide()

func take_damage(damage_ammount):
	if damage_immunity.is_stopped():
		GameManager.damage_or_heal(-damage_ammount)
		hurt_sfx.play()
		modulate = Color.RED
		damage_immunity.start()
		
func _on_damage_immunity_timeout():
	modulate = Color.WHITE
	
func player_death():
	player_dead = true
	chasis_sprite.hide()
	death.play()
	velocity = Vector2(0, 0)
	explosion_sprite.show()
	explosion_sprite.play()

func _on_animated_sprite_2d_animation_finished():
	explosion_sprite.hide()
