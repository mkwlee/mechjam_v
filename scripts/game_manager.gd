extends Node

var keys = 0
var keys_in_hole = 0
var collected_keys = [0, 0, 0]
var unlocked_arms = [1, 0, 0]
var health = 100

@onready var key_hole = %KeyHole
@onready var water_damage_time_out = $WaterDamageTimeOut

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func damage_or_heal(amount):
	if amount > 0:
		health = GUI.player_heal(health, amount)
	elif amount < 0:
		health = GUI.player_damage(health, amount)
	
	if health < 1:
		death()

func add_or_remove_key_to_player(num_of_keys):
	keys = GUI.change_key_progress(keys, num_of_keys)

func add_keys_to_hole():
	keys_in_hole = min(3, keys_in_hole+keys)
	keys = GUI.change_key_progress(keys, -keys)

func death():
	get_tree().reload_current_scene()
	damage_or_heal(100)
	GUI.reset_damage_heal_bar()
