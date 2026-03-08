extends Area2D

#@onready var item=$"."
@export var has_hook:bool=false
@onready var hook_hint=$"../../text labels/hook hint"
# Called when the node enters the scene tree for the first time.
func on_area_entered(other_area):
	hide()
	hook_hint.show()
	$"../../Player".can_wall_slide=true
	
func _ready() -> void:
	hook_hint.hide()
	area_entered.connect(on_area_entered) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
