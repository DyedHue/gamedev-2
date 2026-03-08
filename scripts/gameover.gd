extends Label

var gameover:bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gameover=owner.get_node("apple").gameover
	if(gameover):
		show()
	pass
