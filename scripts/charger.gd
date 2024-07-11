extends RigidBody2D

@onready var chasis_sprite = $ChasisSprite
@onready var fire_sprite = $FireSprite
@onready var spike_sprite = $SpikeSprite

@onready var movement_stop_ray = $MovementStopRay
@onready var enemy_detection_ray = $EnemyDetectionRay

@onready var charge_delay = $ChargeDelay
@onready var cool_down = $CoolDown


@export var SPEED : int
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
	ground = position.y
	air = position.y - 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == actions.WANDER:
		if movement_stop_ray.is_colliding():
			direction *= -1
			flip_sprites()
			linear_velocity.x = direction * SPEED
		
		if enemy_detection_ray.is_colliding():
			if enemy_detection_ray.get_collider().name == 'Player':
				print('Targeting')
				target_location = enemy_detection_ray.get_collision_point()
				prepare_to_charge()
	elif state == actions.PREPARING:
		position.y = move_toward(position.y, air, 16*delta)
	elif state == actions.CHARGING:
		if direction == 1 and position.x > target_location.x or direction == -1 and position.x < target_location.x:
			state = actions.COOLDOWN
			cool_down.start()
	elif state == actions.COOLDOWN:
		linear_velocity.x = move_toward(linear_velocity.x, 0, (SPEED*2)*delta)
		
		if linear_velocity.x == 0:
			position.y = move_toward(position.y, ground, 16*delta)
			
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
	
func prepare_to_charge():
	charge_delay.start()
	linear_velocity.x = 0
	state = actions.PREPARING
	
func charge_at_target():
	linear_velocity.x = direction * SPEED * 2
	spike_sprite.show()
	state = actions.CHARGING

func reset_cycle():
	print('ah')
	spike_sprite.hide()
	linear_velocity.x = direction * SPEED
	state = actions.WANDER
