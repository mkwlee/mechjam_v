extends Area2D

var in_water = false
@export var DAMAGE = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_water and GameManager.water_damage_time_out.is_stopped():
		for body in get_overlapping_bodies():
			body.take_damage(DAMAGE)
			GameManager.water_damage_time_out.start()


func _on_body_entered(body):
	in_water = true


func _on_body_exited(body):
	in_water = false
