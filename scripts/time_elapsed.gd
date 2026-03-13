extends Label
@onready var gameovernode: Label = $"../gameover"

var timer: float = 0
var shown: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shown:
		return
	timer += delta
	if gameovernode.gameover:
		var min: int = timer/60
		var sec: int = timer - min
		var txt = "Time elapsed: %d:" %min
		if sec < 10:
			txt += "0"
		txt += "%d" %sec
		text = txt
		shown =  true
