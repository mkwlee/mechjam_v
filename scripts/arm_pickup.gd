extends Area2D

@export var arm_type : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.unlocked_arms[arm_type] == 1:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	GameManager.unlocked_arms[arm_type] = 1
	if body.name == "Player":
		body.switch_arm(arm_type)
	queue_free()
