extends Area2D

@onready var item=$"."
@export var gate_opened:bool=false
# Called when the node enters the scene tree for the first time.
func on_area_entered(other_area):
	hide()
	$Sprite2D.hide()
	$Sprite2D2.show()
	gate_opened=true
	$"../gateopen".show()
	$"../gate".hide()
	
func _ready() -> void:
	area_entered.connect(on_area_entered) 
	$Sprite2D.show()
	$Sprite2D2.hide()
	$"../gateopen".hide()# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
