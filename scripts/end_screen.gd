extends Control

@onready var loose_label = $LooseLabel
@onready var loose_timer = $LooseTimer
const WORLD = preload("res://scenes/world.tscn")

@onready var win = $Win
@onready var grave_text_middle = $Win/GraveTextMiddle
@onready var grave_text_time = $Win/GraveTextTime
@onready var win_timer = $WinTimer
@onready var win_sfx = $WinSFX

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.meltdown:
		win_timer.start()
	elif not GameManager.meltdown:
		loose_label.show()
		loose_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_loose_timer_timeout():
	GUI.control.show()
	get_tree().change_scene_to_packed(WORLD)


func _on_win_timer_timeout():
	var sol_num = randi_range(111111111, 999999999)
	grave_text_middle.text = "Solider #"+str(sol_num)
	
	
	var min = str(int(GUI.time_elapsed) / 60)
	if min.length() < 2:
		min = '0'+min
		
	var sec = str(int(GUI.time_elapsed) % 60)
	if sec.length() < 2:
		sec = '0'+sec
	
	var msec = str(floor((GUI.time_elapsed-floor(GUI.time_elapsed))*100))
	if msec.length() < 2:
		msec = '0'+msec
		
	grave_text_time.text = min +":"+ sec +":"+ msec
	
	win_sfx.play()
	win.show()
