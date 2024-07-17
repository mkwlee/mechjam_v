extends RigidBody2D

@onready var chasis_sprite = $ChasisSprite
@onready var fire_sprite = $ChasisSprite/FireSprite
@onready var explosion = $ChasisSprite/Explosion

@onready var enemy_detection_ray = $ChasisSprite/EnemyDetectionRay

@onready var chase_delay = $ChaseDelay
@onready var explosion_spread = $ExplosionSpread
@onready var no_enemy_detect_idle_delay = $NoEnemyDetectIdleDelay

@onready var enemy_hurtbox = $"Enemy Hurtbox"

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
		SPAWNER.enemy_dead = true
		queue_free()
	
	
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
				
				if global_position.distance_to(player.global_position) <= 40:
					enter_exploding()
				elif enemy_detection_ray.is_colliding():
					if enemy_detection_ray.get_collider().name == 'Player':
						no_enemy_detect_idle_delay.stop()
					elif no_enemy_detect_idle_delay.is_stopped():
						no_enemy_detect_idle_delay.start()
				pass
			actions.EXPLODING:
				if explosion_size < 0:
					enemy_hurtbox.ACTIVE = true

func enter_idle():
	fire_sprite.hide()
	chasis_sprite.play("default")
	linear_velocity = Vector2(0, 0)
	state = actions.IDLE

func enter_preparing():
	chasis_sprite.play("attack")
	state = actions.PREPARING

func enter_chasing():
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
