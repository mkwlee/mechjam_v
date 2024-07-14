extends RigidBody2D

@onready var sprite = $Sprite2D

@export var HEALTH : int


# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.rotate(PI*delta)

func _on_body_entered(body):
	queue_free()
