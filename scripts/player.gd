extends CharacterBody2D

#Node References
@onready var back_leg_sprite = $BackLegSprite
@onready var chasis_sprite = $ChasisSprite
@onready var front_leg_sprite = $FrontLegSprite

@onready var gun_sprite = $GunSprite
@onready var gun_tip = $GunSprite/GunTip

@onready var charge_sprite = $ChargeSprite
@onready var charge_tip = $ChargeSprite/ChargeTip
@onready var ball_charging = $ChargeSprite/BallCharging

@onready var arms = [[gun_sprite, gun_tip], [charge_sprite, charge_tip]]

#Scene references
const BULLET = preload("res://scenes/bullet.tscn")
const BALL = preload("res://scenes/ball.tscn")

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

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		if direction > 0 and chasis_sprite.flip_h == true:
			flipped_player(false)
		elif direction < 0 and chasis_sprite.flip_h == false:
			flipped_player(true)
			
		velocity.x = direction * SPEED
		back_leg_sprite.play("walk")
		front_leg_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		back_leg_sprite.play("idle")
		front_leg_sprite.play("idle")
		
	

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
			if Input.is_action_just_pressed("shoot"):
				ball_charging.position = charge_tip.position
				ball_charging.scale = Vector2(0.5, 0.5)
				ball_charging.show()
				charge_power_up.start()
			elif Input.is_action_pressed("shoot"):
				ball_charging.position = charge_tip.position
				var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
				ball_charging.scale = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
			elif Input.is_action_just_released("shoot"):
				if ball_charging.visible == true:
					var time_held = floor(CHARGE_POWERUP - charge_power_up.time_left)
					var b = BALL.instantiate()
					b.rotation = charge_tip.global_rotation
					if chasis_sprite.flip_h == true:
							b.direction = -1
					b.position = charge_tip.global_position
					b.speed_multiplier = time_held+1
					b.size = Vector2(0.5+0.25*time_held, 0.5+0.25*time_held)
					ball_charging.hide()
					get_parent().add_child(b)
					charge_sprite.play("shoot")
				
				
			
	
func set_timers():
	gun_cool_down.wait_time = GUN_COOLDOWN
	gun_cool_down.one_shot = true
	charge_power_up.wait_time = CHARGE_POWERUP
	charge_power_up.one_shot = true

func switch_arm():
	if current_arm == 0:
		arms[0][0].hide()
		arms[1][0].show()
		arms[1][1].show()
		current_arm = 1
	else:
		arms[1][0].hide()
		arms[1][1].hide()
		arms[0][0].show()
		arms[0][1].show()
		current_arm = 0
		
