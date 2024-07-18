extends Area2D

const END_SCREEN = preload("res://scenes/end_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		GUI.control.hide()
		get_tree().change_scene_to_packed(END_SCREEN)
