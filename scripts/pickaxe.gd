extends Node2D
@onready var player: CharacterBody2D = $".."
@onready var sprite: Sprite2D= $Sprite2D
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
