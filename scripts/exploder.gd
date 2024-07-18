extends RigidBody2D

@onready var chasis_sprite = $ChasisSprite
@onready var fire_sprite = $ChasisSprite/FireSprite
@onready var explosion = $ChasisSprite/Explosion

@onready var enemy_detection_ray = $ChasisSprite/EnemyDetectionRay

@onready var chase_delay = $ChaseDelay
@onready var explosion_spread = $ExplosionSpread
@onready var no_enemy_detect_idle_delay = $NoEnemyDetectIdleDelay
@onready var flash_interval = $FlashInterval

@onready var explode_hurtbox = $ExplodeHurtbox

@onready var follow_sfx = $FollowSFX
@onready var explode_sfx = $ExplodeSFX
@onready var death_sfx = $DeathSFX

@export var SPEED : int
@export var HEALTH : int
@export var STAGGER = false
@export_enum("left", "right") var facing = "right"
var DEAD = false
var SPAWNER


enum actions {IDLE, PREPARING, CHASING, EXPLODING}
var state = actions.IDLE

var player
var target_location
var explosion_size = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_explosion()
	
	enter_idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if DEAD == true:
		linear_velocity = Vector2(0, 0)
		explode_hurtbox.ACTIVE = false
		chasis_sprite.hide()
		if not death_sfx.playing:
			death_sfx.play()
	
	
	if not STAGGER:
		match state:
			actions.IDLE:
				chasis_sprite.rotate(PI/2 *delta)
				if enemy_detection_ray.is_colliding():
					if enemy_detection_ray.get_collider().name == 'Player':
						player = enemy_detection_ray.get_collider()
						enter_preparing()
						chase_delay.start()
				pass
			actions.PREPARING:
				chasis_sprite.rotation = global_position.angle_to_point(player.gun_tip.global_position)
				pass
			actions.CHASING:
				chasis_sprite.rotation = global_position.angle_to_point(player.global_position)
				var chase_direction = global_position.direction_to(player.gun_tip.global_position).normalized()
				linear_velocity = Vector2(chase_direction.x*SPEED*1.5, chase_direction.y*SPEED)
				
				var distance_to = global_position.distance_to(player.global_position)
				if distance_to < 48:
					enter_exploding()
					pass
				if distance_to < 96:
					flash_interval.wait_time = 0.1
					if flash_interval.is_stopped():
						flash_interval.start()
					pass
				elif distance_to < 192:
					flash_interval.wait_time = 0.3
					if flash_interval.is_stopped():
						flash_interval.start()
					pass
				elif distance_to < 384:
					flash_interval.wait_time = 0.5
					if flash_interval.is_stopped():
						flash_interval.start()
					pass
				else:
					flash_interval.stop()
					modulate = Color.WHITE
					if enemy_detection_ray.is_colliding():
						if enemy_detection_ray.get_collider().name == 'Player':
							no_enemy_detect_idle_delay.stop()
						elif no_enemy_detect_idle_delay.is_stopped():
							no_enemy_detect_idle_delay.start()
						
				#if global_position.distance_to(player.global_position) <= 48:
					#enter_exploding()
				#elif enemy_detection_ray.is_colliding():
					#if enemy_detection_ray.get_collider().name == 'Player':
						#no_enemy_detect_idle_delay.stop()
					#elif no_enemy_detect_idle_delay.is_stopped():
						#no_enemy_detect_idle_delay.start()
				pass
			actions.EXPLODING:
				if explosion_size < 0:
					explode_hurtbox.ACTIVE = true

func enter_idle():
	follow_sfx.stop()
	fire_sprite.hide()
	chasis_sprite.play("default")
	linear_velocity = Vector2(0, 0)
	state = actions.IDLE

func enter_preparing():
	chasis_sprite.play("attack")
	state = actions.PREPARING

func enter_chasing():
	if not follow_sfx.playing:
		follow_sfx.play()
	fire_sprite.show()
	linear_velocity = global_position.direction_to(player.global_position)*SPEED
	state = actions.CHASING

func enter_exploding():
	linear_velocity = Vector2(0, 0)
	state = actions.EXPLODING
	explosion_spread.start()

func animated_explosion():
	if explosion_size < 0:
		SPAWNER.enemy_dead = true
		queue_free()
	else:
		if not explode_sfx.playing:
			explode_sfx.play()
		explosion.get_child(explosion_size).show()
		explosion_size -= 1
		if explosion_size < 0:
			explosion_spread.wait_time = 0.25

func randomize_explosion():
	var flip = randi_range(0, 1)
	explosion.scale.x -= flip*2
	
	flip = randi_range(0, 1)
	explosion.scale.y -= flip*2
	
	flip = randi_range(1, 3)
	explosion.rotation_degrees = flip*90

func exploding_flash():
	if chasis_sprite.self_modulate == Color(1, 1, 1, 1):
		chasis_sprite.self_modulate = Color(100, 100, 100, 1)
	else:
		chasis_sprite.self_modulate = Color(1, 1, 1, 1)


func _on_death_sfx_finished():
	SPAWNER.enemy_dead = true
	queue_free()
