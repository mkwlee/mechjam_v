extends RigidBody2D

# Node references
@onready var chasis_sprite = $ChasisSprite
@onready var fire_sprite = $ChasisSprite/FireSprite
@onready var spike_sprite = $ChasisSprite/SpikeSprite

@onready var movement_stop_ray = $MovementStopRay
@onready var enemy_detection_ray = $EnemyDetectionRay

@onready var charge_delay = $ChargeDelay
@onready var cool_down = $CoolDown

@export var SPEED : int
@export var HEALTH : int
@export var STAGGER = false

var direction = 1
enum actions {WANDER, PREPARING, CHARGING, COOLDOWN}
var state = actions.WANDER
var target_location
var air
var ground


# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1
	linear_velocity.x = direction * SPEED
	chasis_sprite.play("default")
	ground = position.y
	air = position.y - 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not STAGGER:
		if state == actions.WANDER:
			if movement_stop_ray.is_colliding():
				direction *= -1
				flip_sprites()
				linear_velocity.x = direction * SPEED
			
			if enemy_detection_ray.is_colliding():
				if enemy_detection_ray.get_collider().name == 'Player':
					enter_preparing()
					charge_delay.start()
					
		elif state == actions.PREPARING:
			position.y = move_toward(position.y, air, (16 / charge_delay.wait_time)*delta)
			
		elif state == actions.CHARGING:
			if direction == 1 and position.x > target_location.x or direction == -1 and position.x < target_location.x:
				fire_sprite.play("default")
				linear_velocity.x = move_toward(linear_velocity.x, 0, (SPEED*2)*delta)
				if linear_velocity.x == 0:
					enter_cooldown()
					cool_down.start()
				
		elif state == actions.COOLDOWN:
			position.y = move_toward(position.y, ground, (16 / cool_down.wait_time)*delta)
	else:
		if state == actions.PREPARING:
			charge_delay.paused = true
		elif state == actions.COOLDOWN:
			cool_down.paused = true
		linear_velocity.x = 0
		spike_sprite.pause()
		fire_sprite.pause()
			
func flip_sprites():
	if direction > 0:
		chasis_sprite.flip_h = false
		fire_sprite.flip_h = false
		spike_sprite.flip_h = false
	else:
		chasis_sprite.flip_h = true
		fire_sprite.flip_h = true
		spike_sprite.flip_h = true
		
	fire_sprite.position.x *= -1
	spike_sprite.position.x *= -1
	movement_stop_ray.target_position.x *= -1
	enemy_detection_ray.target_position.x *= -1

func enter_wander():
	linear_velocity.x = direction * SPEED
	chasis_sprite.play("default")
	fire_sprite.play("default")
	fire_sprite.show()
	state = actions.WANDER

func enter_preparing():
	target_location = enemy_detection_ray.get_collision_point()
	linear_velocity.x = 0
	chasis_sprite.play("attack")
	fire_sprite.hide()
	spike_sprite.play("default")
	state = actions.PREPARING

func enter_charging():
	linear_velocity.x = direction * SPEED * 2
	fire_sprite.play("charging")
	fire_sprite.show()
	state = actions.CHARGING

func enter_cooldown():
	fire_sprite.hide()
	spike_sprite.play_backwards("default")
	state = actions.COOLDOWN

func exit_stagger():
	STAGGER = false
	match state:
		actions.WANDER:
			enter_wander()
			pass
		actions.PREPARING:
			enter_preparing()
			charge_delay.paused = false
		actions.CHARGING:
			enter_charging()
		actions.COOLDOWN:
			enter_cooldown()
			cool_down.paused = false
	
			
