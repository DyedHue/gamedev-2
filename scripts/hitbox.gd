class_name myhitbox
extends Area2D

@onready var has_pickaxe
@onready var col = $CollisionShape2D

var timer: float = 0

func _init() -> void:
	collision_layer = 2
	collision_mask = 0

func _ready() -> void:
	# Start with the hitbox disabled
	col.set_deferred("disabled", true)

func _process(delta) -> void:
	has_pickaxe=$"../..".has_pickaxe
	if Input.is_action_just_pressed("attack"):
		col.set_deferred("disabled", !has_pickaxe)
		timer = 0.1
		
	if timer > 0:
		timer -= delta
		if timer <= 0:
			col.set_deferred("disabled", true)
