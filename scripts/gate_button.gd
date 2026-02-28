extends Area2D

@onready var item=$"."
@export var gate_opened:bool=false
# Called when the node enters the scene tree for the first time.
func on_area_entered(other_area):
	hide()
	gate_opened=true
	
func _ready() -> void:
	area_entered.connect(on_area_entered) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
