extends CharacterBody2D

#Node References
@onready var back_leg_sprite = $BackLegSprite
@onready var chasis_sprite = $ChasisSprite
@onready var front_leg_sprite = $FrontLegSprite

@onready var gun_sprite = $ChasisSprite/GunSprite
@onready var gun_tip = $ChasisSprite/GunSprite/GunTip


@onready var charge_sprite = $ChasisSprite/ChargeSprite
@onready var charge_tip = $ChasisSprite/ChargeSprite/ChargeTip
@onready var ball_sprite = $ChasisSprite/ChargeSprite/BallSprite


@onready var thrower_sprite = $ChasisSprite/ThrowerSprite
@onready var thrower_tip = $ChasisSprite/ThrowerSprite/ThrowerTip
@onready var fire_sprite = $ChasisSprite/ThrowerSprite/Fire/FireSprite
@onready var fire_collision = $ChasisSprite/ThrowerSprite/Fire/FireCollision
@onready var fire_ray_cast = $ChasisSprite/ThrowerSprite/Fire/FireRayCast

@onready var arms = [[gun_sprite, gun_tip], [charge_sprite, charge_tip], [thrower_sprite, thrower_tip]]

#Scene references
const BULLET = preload("res://scenes/bullet.tscn")
const BALL = preload("res://scenes/ball.tscn")
const FIRE = preload("res://scenes/fire.tscn")

@export var SPEED : int
@export var JUMP : int

#Timer References
@onready var gun_cool_down = $Timers/GunCoolDown
@onready var charge_power_up = $Timers/ChargePowerUp

@export var GUN_COOLDOWN : float
@export var CHARGE_POWERUP : float

var current_arm = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	set_timers()
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		if direction > 0 and chasis_sprite.flip_h == true:
			flipped_player(false)
		elif direction < 0 and chasis_sprite.flip_h == false:
			flipped_player(true)
			
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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP
		back_leg_sprite.play("jump")
		front_leg_sprite.play("jump")
		


	move_and_slide()
	rotate_arm_up()
	shoot_gun()
	
		
		
	if Input.is_action_just_pressed("switch_arm"):
		switch_arm()

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
	#var hyp = gun_sprite.global_position.direction_to(get_global_mouse_position())
	#var disp = (sinh(8.5/gun_sprite.global_position.distance_to(get_global_mouse_position())))
	#gun_sprite.rotation = hyp.angle() - disp
	#
	#if chasis_sprite.flip_h == true:
		#gun_sprite.rotation = hyp.angle() + disp + PI
	
	if Input.is_action_pressed("up"):
		for a in arms:
			if a[0].flip_h == false:
				a[0].rotation_degrees = -90
			else:
				a[0].rotation_degrees = 90
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
					if chasis_sprite.flip_h == true:
						b.direction = -1
					b.position = gun_tip.global_position
					get_parent().add_child(b)
					gun_sprite.play("shoot")
					gun_cool_down.start()
			pass
		1: #Charge
			if Input.is_action_just_pressed("shoot"): #Start of charge
				ball_sprite.position = charge_tip.position
				ball_sprite.scale = Vector2(0.5, 0.5)
				ball_sprite.show()
				charge_power_up.start()
			elif Input.is_action_pressed("shoot"): #During charge
				ball_sprite.position = charge_tip.position
				var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
				ball_sprite.scale = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
				ball_sprite.rotate(PI/2)
			elif Input.is_action_just_released("shoot"): #Release charge
				if ball_sprite.visible == true:
					var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
					var b = BALL.instantiate()
					b.rotation = charge_tip.global_rotation
					if chasis_sprite.flip_h == true:
							b.direction = -1
					b.position = charge_tip.global_position
					b.damage_multiplier = pow(10, time_held)
					b.speed_multiplier = time_held+1
					b.size = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
					ball_sprite.hide()
					get_parent().add_child(b)
					charge_sprite.play("shoot")
			pass
		2: #Thrower
			if Input.is_action_pressed("shoot"):
				fire_collision.disabled = false
				fire_ray_cast.enabled = true
				if fire_ray_cast.is_colliding():
					var ray_size = thrower_tip.global_position.distance_to(fire_ray_cast.get_collision_point())
					print(ray_size/96)
					fire_sprite.scale.x = ray_size/96
				else:
					fire_sprite.scale.x = 1
				
				fire_sprite.global_rotation = thrower_tip.global_rotation
				fire_ray_cast.global_rotation = thrower_tip.global_rotation
				fire_sprite.global_position = thrower_tip.global_position
				fire_ray_cast.global_position = thrower_tip.global_position

				fire_sprite.show()
				fire_sprite.play("fire")
			else:
				fire_collision.disabled = true
				fire_ray_cast.enabled = false
				fire_sprite.scale.x = 1
				fire_sprite.hide()
			
	
func set_timers():
	gun_cool_down.wait_time = GUN_COOLDOWN
	gun_cool_down.one_shot = true
	charge_power_up.wait_time = CHARGE_POWERUP
	charge_power_up.one_shot = true

func switch_arm():
	if current_arm == 2:
		current_arm = 0
	else:
		current_arm += 1
		
	for a in 3:
		if a == current_arm:
			arms[a][0].show()
			arms[a][1].show()
		else:
			arms[a][0].hide()
