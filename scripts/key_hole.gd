extends Area2D

@onready var key_sprites = [$Node2D/Key1, $Node2D/Key2, $Node2D/Key3]


# Called when the node enters the scene tree for the first time.
func _ready():
	for key in GameManager.keys_in_hole:
			key_sprites[key].show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_entered(body):
	if body.name == "Player" and GameManager.keys > 0:
		GameManager.add_keys_to_hole()
		for key in GameManager.keys_in_hole:
			key_sprites[key].show()
