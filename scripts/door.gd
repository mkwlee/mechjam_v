extends StaticBody2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var button = $Button

@export_enum('Bullet', 'Charge', 'Fire') var DOOR_TYPE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if animated_sprite.frame == 9:
		queue_free()

func _on_button_body_entered(body):
	if body.proj_type == DOOR_TYPE:
		button.queue_free()
		open_door()

func _on_button_area_entered(area):
	if area.proj_type == DOOR_TYPE:
		button.queue_free()
		open_door()

func open_door():
	animated_sprite.play()
