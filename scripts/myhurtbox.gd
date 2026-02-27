class_name myhurtbox
extends Area2D

var col

func _init() -> void:
	collision_layer=0
	collision_mask=2
	
func _ready()->void:
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox: myhitbox):
		if (hitbox==null or !Input.is_action_pressed("attack")):
			return
		get_parent().queue_free()
		
