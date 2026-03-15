extends Node2D
@onready var player: CharacterBody2D = $".."
@onready var walk: AudioStreamPlayer = $"../../SFX/walk"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if abs(player.velocity.x) > 600 and player.is_on_floor():
		walk.pitch_scale = 1.4
		if !walk.playing:
			walk.play()
	elif player.velocity.x != 0 and player.is_on_floor():
		walk.pitch_scale = 1.18
		if !walk.playing:
			walk.play()
	else:
		if walk.playing:
			walk.stop()
