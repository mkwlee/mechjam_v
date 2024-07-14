extends Area2D

@export var ENEMY : Node2D
@export var DAMAGE : int
@export var ACTIVE : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if ACTIVE:
		if body.name == "Player":
			body.take_damage(DAMAGE)
			print(body.HEALTH)
