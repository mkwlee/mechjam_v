extends Area2D

@onready var key_sprites = [$Node2D/Key1, $Node2D/Key2, $Node2D/Key3]
@onready var key_insert_sfx = $KeyInsertSFX
@onready var key_passive_sfx = $KeyPassiveSFX


# Called when the node enters the scene tree for the first time.
func _ready():
	for key in GameManager.keys_in_hole:
			key_sprites[key].show()
	key_passive_sfx.volume_db= 5*GameManager.keys_in_hole
	key_passive_sfx.pitch_scale = 0.25+0.25*GameManager.keys_in_hole
	key_passive_sfx.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.name == "Player" and GameManager.keys > 0:
		GameManager.add_keys_to_hole()
		for key in GameManager.keys_in_hole:
			key_sprites[key].show()
		key_insert_sfx.play()
		
		key_passive_sfx.volume_db= 5*GameManager.keys_in_hole
		key_passive_sfx.pitch_scale = 0.25+0.25*GameManager.keys_in_hole
		if not key_passive_sfx.playing:
			key_passive_sfx.play()
		if GameManager.keys_in_hole == 3 and not GameManager.meltdown:
			GameManager.start_meltdown()
