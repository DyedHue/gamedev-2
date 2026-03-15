extends Sprite2D

@export var rotation_amount: float = 50.0

var is_attacking: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		spin_attack()

func spin_attack() -> void:
	is_attacking = true
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", rotation_degrees + rotation_amount, 0.1)
	tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.15)
	tween.finished.connect(_on_attack_finished)

func _on_attack_finished() -> void:
	is_attacking = false
	
	rotation_degrees = wrapf(rotation_degrees, 0.0, 360.0)
