extends Camera2D

@export_group("Targeting")
@export var player: CharacterBody2D
@export var follow_speed: float = 6.0 

@export_group("Horizontal Advance (Lead)")
@export var lead_distance: float = 180.0
@export var lead_snap_speed: float = 2.0

@export_group("Vertical Look (The Pan)")
@export var pan_speed: float = 800.0 
@export var max_pan_up: float = 150.0
@export var max_pan_down: float = 200.0
@export var look_delay: float = 0.2

var home_local_pos: Vector2
var current_lead_x: float = 0.0
var current_pan_y: float = 0.0
var look_timer: float = 0.0

var current_shake_intensity: float = 0.0

func _ready() -> void:
	home_local_pos = position
	top_level = true
	if player:
		global_position = player.global_position + home_local_pos

func _process(_delta: float) -> void:
	if current_shake_intensity > 0:
		offset = Vector2(
			randf_range(-1.0, 1.0) * current_shake_intensity,
			randf_range(-1.0, 1.0) * current_shake_intensity
		)
	else:
		offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not player: return

	var h_input = Input.get_axis("move_left", "move_right")
	var target_lead = h_input * lead_distance
	
	if h_input != 0:
		current_lead_x = lerp(current_lead_x, target_lead, lead_snap_speed * delta)
	else:
		current_lead_x = lerp(current_lead_x, 0.0, (lead_snap_speed * 0.5) * delta)

	handle_vertical_look(delta)

	var advanced_target = player.global_position + home_local_pos
	advanced_target.x += current_lead_x
	advanced_target.y += current_pan_y

	global_position = global_position.lerp(advanced_target, follow_speed * delta)

func handle_vertical_look(delta: float) -> void:
	var v_input = Input.get_axis("up", "down")
	var is_moving_horizontally = abs(player.velocity.x) > 100.0
	
	if v_input != 0 and player.is_on_floor() and not is_moving_horizontally:
		look_timer += delta
		if look_timer >= look_delay:
			current_pan_y += v_input * pan_speed * delta
	else:
		look_timer = 0
		current_pan_y = move_toward(current_pan_y, 0, pan_speed * delta)
	
	current_pan_y = clamp(current_pan_y, -max_pan_up, max_pan_down)

func start_shake(intensity: float) -> void:
	current_shake_intensity = intensity

func stop_shake() -> void:
	current_shake_intensity = 0.0
