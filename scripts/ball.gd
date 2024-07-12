extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

@export var BASE_SPEED : int
@export var MAX_SPEED : int
@export var DAMAGE : int
var direction = 1

var speed_multiplier
var damage_multiplier
var size

# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1
	
	DAMAGE *= damage_multiplier
	
	sprite.scale = size
	collision_shape.shape.radius = collision_shape.shape.radius*size.x
	
	var speed_mod = (MAX_SPEED - BASE_SPEED) / 3
	linear_velocity.x = cos(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))*direction
	linear_velocity.y = sin(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))*direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body):
	if body.name == "TileMap":
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
