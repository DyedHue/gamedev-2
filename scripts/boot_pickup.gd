extends Area2D

@onready var item=$"."
@export var has_boots:bool=false
# Called when the node enters the scene tree for the first time.
func on_area_entered(other_area):
	hide()
	has_boots=true
	
func _ready() -> void:
	area_entered.connect(on_area_entered) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
