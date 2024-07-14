extends Area2D

@export var ENEMY : Node2D
@export var DAMAGE : int
@export var ACTIVE : bool = true

var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ACTIVE:
		if attacking:
			for body in get_overlapping_bodies():
				body.take_damage(DAMAGE)

func _on_body_entered(body):
	attacking = true
		

func _on_body_exited(body):
	attacking = false
