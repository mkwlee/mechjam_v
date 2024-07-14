extends Area2D

@export var ENEMY : Node2D
@export var SPRITE : Node2D
@export var ACTIVE : bool = true
@export var STAGGER_THRESHOLD : int

@onready var impact_timer = $ImpactTimer

var on_fire = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ACTIVE:
		if on_fire == true:
			for area in get_overlapping_areas():
				ENEMY.HEALTH = damage_and_stagger(ENEMY.HEALTH, area.DAMAGE*delta)
				#print(ENEMY.HEALTH)
				if ENEMY.HEALTH < 1:
					ENEMY.queue_free()
				else:
					impact_timer.start()
			
func _on_body_entered(body):
	if ACTIVE:
		ENEMY.HEALTH = damage_and_stagger(ENEMY.HEALTH, body.DAMAGE)
		
		if ENEMY.HEALTH < 1:
			ENEMY.queue_free()
		else:
			impact_timer.start()
			
		body.queue_free()

func damage_and_stagger(health, damage):
	SPRITE.modulate = Color.RED
	if health - (health-damage) >= STAGGER_THRESHOLD:
		ENEMY.STAGGER = true
	return health - damage

func _on_impact_timer_timeout():
	SPRITE.modulate = Color.WHITE
	
	if ENEMY.STAGGER == true:
		ENEMY.exit_stagger()

func _on_area_entered(area):
	on_fire = true

func _on_area_exited(area):
	on_fire = false
