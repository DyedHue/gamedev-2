extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var originalx: float

func _ready() -> void:
	originalx = position.x

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	position.x = originalx
