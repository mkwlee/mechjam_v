extends Area2D

@export var key_num : int
@onready var key_pickup_sfx = $KeyPickupSFX
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.collected_keys[key_num]:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		GameManager.add_or_remove_key_to_player(1)
		GameManager.damage_or_heal(50)
		GameManager.collected_keys[key_num] = 1
		key_pickup_sfx.play()
		sprite.queue_free()
		collision_shape.queue_free()


func _on_key_pickup_sfx_finished():
	queue_free()
