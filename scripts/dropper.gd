extends RigidBody2D

@onready var chasis_sprite = $ChasisSprite
@onready var mouth_sprite = $ChasisSprite/MouthSprite

@onready var movement_stop_ray = $ChasisSprite/MovementStopRay
@onready var enemy_detection_ray = $ChasisSprite/EnemyDetectionRay

@onready var drop_point = $ChasisSprite/DropPoint

@export var SPEED : int
@export var HEALTH : int
@export var STAGGER = false
@export_enum("left", "right") var facing = "right"

@onready var wander_drop = $WanderDrop

const DROPPER_PROJECTILE = preload("res://scenes/dropper_projectile.tscn")

var direction = 1
enum actions {WANDER, PREPARING, FOLLOWING, COOLDOWN}
var state = actions.WANDER

# Called when the node enters the scene tree for the first time.
func _ready():
	if facing == "left":
		direction *= -1
		chasis_sprite.scale.x *= -1
	enter_wander()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		actions.WANDER:
			if movement_stop_ray.is_colliding():
				direction *= -1
				chasis_sprite.scale.x *= -1
				linear_velocity.x = direction * SPEED
			elif enemy_detection_ray.is_colliding():
				if enemy_detection_ray.get_collider().name == 'Player':
					#drop_projectile()
					pass
			
			if mouth_sprite.frame == 3:
				var p = DROPPER_PROJECTILE.instantiate()
				p.global_position = drop_point.global_position
				get_parent().add_child(p)
				mouth_sprite.play_backwards("default")

func enter_wander():
	linear_velocity.x = direction * SPEED
	wander_drop.start()

func enter_preparing():
	pass

func enter_following():
	pass

func enter_cooldown():
	pass

func drop_projectile():
	mouth_sprite.play("default")
