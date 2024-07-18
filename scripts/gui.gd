extends CanvasLayer

@onready var control = $Control
@onready var damage_bar = $Control/MarginContainer/DamageBar
@onready var heal_bar = $Control/MarginContainer/HealBar
@onready var health_bar = $Control/MarginContainer/HealthBar
@onready var key_progress = $Control/MarginContainer/KeyProgress
@onready var game_time = $Control/MarginContainer/GameTime
@onready var screen_flash = $ScreenFlash
@onready var red_flash = $Control/RedFlash
@onready var screen_flash_blip = $ScreenFlashBlip
@onready var meltdown_time_label = $Control/MarginContainer/MeltdownTimeLabel

@onready var damage_heal_bar = $DamageHealBar

var time_elapsed : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	key_progress.value = GameManager.keys

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.meltdown:
		game_time.hide()
		meltdown_time_label.show()
		var time_left = GameManager.meltdown_timer.time_left
		
		var min = str(int(time_left) / 60)
		if min.length() < 2:
			min = '0'+min
			
		var sec = str(int(time_left) % 60)
		if sec.length() < 2:
			sec = '0'+sec
		
		var msec = str(floor((time_left-floor(time_left))*100))
		if msec.length() < 2:
			msec = '0'+msec
			
		meltdown_time_label.text = min +":"+ sec +":"+ msec
	else:
		time_elapsed += delta
		var min = str(int(time_elapsed) / 60)
		if min.length() < 2:
			min = '0'+min
			
		var sec = str(int(time_elapsed) % 60)
		if sec.length() < 2:
			sec = '0'+sec
		
		var msec = str(floor((time_elapsed-floor(time_elapsed))*100))
		if msec.length() < 2:
			msec = '0'+msec
			
		game_time.text = min +":"+ sec +":"+ msec

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
		health_bar.value = heal_bar.value
		damage_bar.value = heal_bar.value

func change_key_progress(num_of_keys, change_amount):
	if change_amount > 0:
		key_progress.value = min(3, num_of_keys+change_amount)
	elif change_amount < 0:
		key_progress.value = max(0, num_of_keys+change_amount)
	return key_progress.value

func start_screen_flash():
	screen_flash.start()

func _on_screen_flash_timeout():
	red_flash.show()
	screen_flash_blip.start()
	
func _on_screen_flash_blip_timeout():
	red_flash.hide()
	meltdown_time_label.add_theme_font_size_override("font_size", meltdown_time_label.get_theme_font_size("font_size")+6)
		
	
