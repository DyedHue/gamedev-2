extends Sprite2D
@onready var player: CharacterBody2D = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.position.x > 4571.0 && player.position.y < 3486.0:
		visible = true
	else:
		visible = false
