extends RigidBody2D

@onready var sprite = $Sprite2D

@export var BASE_SPEED : int
@export var MAX_SPEED : int
var direction = 1

var speed_multiplier
var size

# Called when the node enters the scene tree for the first time.
func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	sprite.scale = size
	var speed_mod = (MAX_SPEED - BASE_SPEED) / 3
	linear_velocity.x = cos(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))*direction
	linear_velocity.y = sin(rotation)*(BASE_SPEED+(speed_multiplier*speed_mod))*direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_body_entered(body):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
