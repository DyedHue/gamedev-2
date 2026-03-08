extends Area2D

@onready var item=$"."
@export var has_boots:bool=false
@onready var boot_hint=$"../../text labels/boot_hint"
# Called when the node enters the scene tree for the first time.
func on_area_entered(_other_area):
	hide()
	boot_hint.show()
	has_boots=true
	
func _ready() -> void:
	area_entered.connect(on_area_entered)
	boot_hint.hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
