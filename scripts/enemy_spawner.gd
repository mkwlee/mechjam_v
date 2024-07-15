extends Node2D

@onready var sprite = $Sprite
@onready var spawn_location_notifier = $SpawnLocationNotifier
@onready var death_location_notifier = $DeathLocationNotifier
@onready var off_screen_timer = $OffScreenTimer


@export var ENEMY_TYPE : PackedScene
@export_enum("left", "right") var direction = "left"

var enemy
var enemy_dead = true
var active = true


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not enemy_dead and enemy != null:
		death_location_notifier.global_position = enemy.global_position

func spawner_screen_entered():
	if active and enemy_dead:
		spawn_enemy()
		enemy_dead = false
		active = false

func spawner_screen_exited():
	pass
	
func death_location_screen_entered():
	off_screen_timer.stop()
	print('STOP')
	
func death_location_screen_exited():
	if enemy_dead:
		active = true
	else:
		off_screen_timer.start()
		print('START')

func spawn_enemy():
	enemy = ENEMY_TYPE.instantiate()
	enemy.global_position = global_position
	enemy.facing = direction
	enemy.SPAWNER = self
	get_tree().current_scene.add_child(enemy)

func is_off_screen_long():
	print('DIED OFF SCREEN')
	enemy_dead = true
	active = true
	enemy.queue_free()
		
