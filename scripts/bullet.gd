extends RigidBody2D

@export var SPEED : int
@export var DAMAGE : int

var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1
	linear_velocity.x = cos(rotation)*SPEED*direction
	linear_velocity.y = sin(rotation)*SPEED*direction
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "TileMap":
		queue_free()
	elif gravity_scale == 0 and body.name != "Tilemap":
		gravity_scale = 1
	else:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
