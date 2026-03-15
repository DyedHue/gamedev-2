extends Area2D

@onready var item=$"."
@export var gate_opened:bool=false
@onready var gate=$"../text labels/gate"
@onready var gate_open=$"../text labels/gateopen"
# Called when the node enters the scene tree for the first time.
func on_area_entered(other_area):
	#hide()
	$Sprite2D.hide()
	$Sprite2D2.show()
	gate_opened=true
	gate_open.show()
	gate.hide()
	$"../SFX/Button press".play()
	$CollisionShape2D.set_deferred("disabled", true)
	
func _ready() -> void:
	area_entered.connect(on_area_entered) 
	$Sprite2D.show()
	$Sprite2D2.hide()
	gate_open.hide()# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
