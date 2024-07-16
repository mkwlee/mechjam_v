extends Node

var keys = 0
var unlocked_arms = [1, 0, 0]
var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func damage_or_heal(amount):
	if amount > 0:
		health = GUI.player_heal(health, amount)
		print('HEAL')
		print(health)
	elif amount < 0:
		health = GUI.player_damage(health, amount)
		print('DAMAGE')
		print(health)
