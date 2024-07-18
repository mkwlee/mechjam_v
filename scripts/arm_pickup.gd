extends Area2D

@export var arm_type : int = 0
@onready var arm_pickup_sfx = $ArmPickupSFX
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.unlocked_arms[arm_type] == 1:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	GameManager.unlocked_arms[arm_type] = 1
	if body.name == "Player":
		body.switch_arm(arm_type)
		arm_pickup_sfx.play()
		sprite.queue_free()
		collision_shape.queue_free()


func _on_arm_pickup_sfx_finished():
	queue_free()
