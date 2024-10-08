extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var hit_sfx = $HitSFX
@onready var scraps = $Scraps

@export var HEALTH : int
var DEAD = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_continuous_collision_detection_mode(CCD_MODE_CAST_RAY)
	contact_monitor = true
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if DEAD == true:
		queue_free()
	sprite.rotate(PI*delta)

func _on_body_entered(_body):
	if not hit_sfx.playing:
		scraps.ACTIVE = false
		sprite.hide()
		hit_sfx.play()
	


func _on_hit_sfx_finished():
	queue_free()
