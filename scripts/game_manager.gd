extends Node

var keys = 0
var keys_in_hole = 0
var collected_keys = [0, 0, 0]
var unlocked_arms = [1, 1, 1]
var health = 100
var dead = false

var meltdown = false
@onready var meltdown_timer = $MeltdownTimer

@onready var water_damage_time_out = $WaterDamageTimeOut
@onready var death_time_out = $DeathTimeOut

const END_SCREEN = preload("res://scenes/end_screen.tscn")

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
	death_time_out.start()
	dead = true

func _on_death_time_out_timeout():
	get_tree().reload_current_scene()
	damage_or_heal(100)
	dead = false
	GUI.reset_damage_heal_bar()

func start_meltdown():
	meltdown = true
	meltdown_timer.start()
	GUI.start_screen_flash()

func _on_meltdown_timer_timeout():
	GUI.control.hide()
	get_tree().change_scene_to_packed(END_SCREEN)
