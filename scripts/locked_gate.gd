extends CharacterBody2D


var gate_opened: bool
var ori_position
func _ready() -> void:
	ori_position=position
func _physics_process(delta: float) -> void:
	gate_opened=$"../Gate_button".gate_opened
	if(gate_opened):
		position.y=ori_position.y-600
