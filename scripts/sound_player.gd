extends Node2D
@onready var player: CharacterBody2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if player.velocity.x != 0 and player.is_on_floor():
		#$"../../SFX/walk".play()
