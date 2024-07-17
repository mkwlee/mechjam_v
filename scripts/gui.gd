extends CanvasLayer

@onready var damage_bar = $Control/MarginContainer/DamageBar
@onready var heal_bar = $Control/MarginContainer/HealBar
@onready var health_bar = $Control/MarginContainer/HealthBar
@onready var key_progress = $Control/MarginContainer/KeyProgress


@onready var damage_heal_bar = $DamageHealBar



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_damage(health, damage_amount):
	damage_bar.value = health_bar.value
	health_bar.value = max(0, health+damage_amount)
	heal_bar.value = health_bar.value
	damage_heal_bar.start()
	return health_bar.value

func player_heal(health, heal_amount):
	heal_bar.value = min(100, health+heal_amount)
	damage_heal_bar.start()
	return heal_bar.value

func reset_damage_heal_bar():
	if damage_bar.value > health_bar.value:
		damage_bar.value = health_bar.value
	elif heal_bar.value > damage_bar.value:
		print('ahj')
		health_bar.value = heal_bar.value
		damage_bar.value = heal_bar.value

func change_key_progress(num_of_keys, change_amount):
	if change_amount > 0:
		key_progress.value = min(3, num_of_keys+change_amount)
	elif change_amount < 0:
		key_progress.value = max(0, num_of_keys+change_amount)
	return key_progress.value
