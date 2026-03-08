extends Area2D

@export var has_dash_boots=false
@onready var dash_boot_hint=$"../text labels/dash boot hint"

func on_area_entered(other_area):
	hide()
	dash_boot_hint.show()
	has_dash_boots=true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(on_area_entered)
	dash_boot_hint.hide()
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
