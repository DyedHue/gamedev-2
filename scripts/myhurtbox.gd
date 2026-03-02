class_name myhurtbox
extends Area2D

var col
@onready var block_falling:bool=false

func _init() -> void:
	collision_layer=0
	collision_mask=2
	
func _ready()->void:
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox: myhitbox):
		if (hitbox==null or !Input.is_action_pressed("attack") or block_falling):
			return
		get_parent().queue_free()
		$"../../../Player".timer=$"../../../Player".delay
