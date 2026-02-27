class_name myhitbox
extends Area2D

# Use @onready to find the child once the node enters the scene tree
@onready var col = $CollisionShape2D

var timer: float = 0

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
	# Do NOT use $ here. Wait for _ready.

func _ready() -> void:
	# Start with the hitbox disabled
	col.set_deferred("disabled", true)

func _process(delta) -> void:
	#pass
	 #1. Start the attack
	if Input.is_action_just_pressed("attack"):
		col.set_deferred("disabled", false)
		timer = 0.1 # Set a small window of time for the hit
		
	# 2. Count down the timer if an attack is active
	if timer > 0:
		timer -= delta
		# 3. Disable when time runs out
		if timer <= 0:
			col.set_deferred("disabled", true)
