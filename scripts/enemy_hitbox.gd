extends Area2D

@export var ENEMY : Node2D
@export var SPRITE : Node2D
@export var STAGGER_THRESHOLD : int

@onready var impact_timer = $ImpactTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	SPRITE.modulate = Color.RED
	ENEMY.HEALTH = damage_and_stagger(ENEMY.HEALTH, body.DAMAGE)
	if ENEMY.HEALTH < 1:
		ENEMY.queue_free()
	else:
		impact_timer.start()
		
	body.queue_free()

func damage_and_stagger(health, damage):
	if health - (health-damage) >= STAGGER_THRESHOLD:
		ENEMY.STAGGER = true
	return health - damage

func _on_impact_timer_timeout():
	SPRITE.modulate = Color.WHITE
	ENEMY.exit_stagger()
