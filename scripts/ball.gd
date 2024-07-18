extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var ball_hit = $BallHit


@export var BASE_SPEED : int
@export var MAX_SPEED : int
@export var DAMAGE : int
var direction = 1

var speed_multiplier
var damage_multiplier
var size
var proj_type = 1
var grow = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1
	
	DAMAGE *= damage_multiplier
	
	sprite.scale = size
	collision_shape.shape.radius = collision_shape.shape.radius*size.x
	
	var speed_mod = (MAX_SPEED - BASE_SPEED) / 3
	linear_velocity.x = cos(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))
	linear_velocity.y = sin(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.rotate(PI/2)
	if grow:
		sprite.scale += Vector2(delta, delta)
	
func _on_body_entered(_body):
	ball_hit.play()
	call_deferred("set_contact_monitor", false)
	collision_mask = 0
	linear_velocity = Vector2(0, 0)
	grow = true


func _on_ball_hit_finished():
	queue_free()
