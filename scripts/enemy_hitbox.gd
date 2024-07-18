extends Area2D

@export var ENEMY : Node2D
@export var SPRITE : Node2D
@export var ACTIVE : bool = true
@export var STAGGER : bool = true
@export var STAGGER_THRESHOLD : int

@onready var impact_timer = $ImpactTimer

var on_fire = false
var dying = false
var burn_damage = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ACTIVE:
		if on_fire == true:
			for area in get_overlapping_areas():
				ENEMY.HEALTH = damage_and_stagger(ENEMY.HEALTH, (area.DAMAGE*delta)+(area.DAMAGE*delta / 2) * floor(burn_damage / 0.5))
				burn_damage += delta
				if ENEMY.HEALTH < 1:
					dying = true
				else:
					impact_timer.start()
		else:
			burn_damage = 0.0
			
func _on_body_entered(body):
	if ACTIVE:
		ENEMY.HEALTH = damage_and_stagger(ENEMY.HEALTH, body.DAMAGE)
		
		if ENEMY.HEALTH < 1:
			dying = true
			
		impact_timer.start()

func damage_and_stagger(health, damage):
	SPRITE.modulate = Color.RED
	if STAGGER:
		if health - (health-damage) >= STAGGER_THRESHOLD:
			ENEMY.STAGGER = true
	return health - damage

func _on_impact_timer_timeout():
	if dying:
		if ENEMY.DEAD == false:
			GameManager.damage_or_heal(8)
		ENEMY.DEAD = true
		
	else:
		SPRITE.modulate = Color.WHITE
		if STAGGER:
			if ENEMY.STAGGER == true:
				ENEMY.STAGGER = false
				ENEMY.exit_stagger()

func _on_area_entered(_area):
	on_fire = true

func _on_area_exited(_area):
	on_fire = false
