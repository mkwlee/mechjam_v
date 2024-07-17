extends Area2D

@export var key_num : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.collected_keys[key_num]:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		GameManager.add_or_remove_key_to_player(1)
		GameManager.damage_or_heal(50)
		GameManager.collected_keys[key_num] = 1
		queue_free()
