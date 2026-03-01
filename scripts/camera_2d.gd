extends Camera2D

@export_group("Targeting")
@export var player: CharacterBody2D
## Higher = Camera sticks closer to player. Lower = More "weight" and lag.
@export var follow_speed: float = 6.0 

@export_group("Horizontal Advance (Lead)")
## How far AHEAD of the player the camera should stay
@export var lead_distance: float = 180.0
## How fast the camera snaps to the "Advanced" side when you switch directions
@export var lead_snap_speed: float = 2.0

@export_group("Vertical Look (The Pan)")
## Speed of the look up/down (Made FASTER)
@export var pan_speed: float = 800.0 
## Distance it can pan UP (Made smaller as requested)
@export var max_pan_up: float = 150.0
## Distance it can pan DOWN (Made smaller as requested)
@export var max_pan_down: float = 200.0
@export var look_delay: float = 0.2

# --- Internal Variables ---
var home_local_pos: Vector2
var current_lead_x: float = 0.0
var current_pan_y: float = 0.0
var look_timer: float = 0.0

func _ready() -> void:
	home_local_pos = position
	top_level = true # Allows us to control smoothing manually
	if player:
		global_position = player.global_position + home_local_pos

func _physics_process(delta: float) -> void:
	if not player: return

	# 1. HORIZONTAL ADVANCE
	# We check input to decide which side the camera should "Advance" to
	var h_input = Input.get_axis("move_left", "move_right")
	var target_lead = h_input * lead_distance
	
	# If moving, we snap the lead quickly so it stays in FRONT of the player
	if h_input != 0:
		current_lead_x = lerp(current_lead_x, target_lead, lead_snap_speed * delta)
	else:
		# When stopped, we return to center much slower
		current_lead_x = lerp(current_lead_x, 0.0, (lead_snap_speed * 0.5) * delta)

	# 2. VERTICAL PAN (Look Up/Down)
	handle_vertical_look(delta)

	# 3. CALCULATE THE "ADVANCED" TARGET
	# This point is already pushed ahead of the player in world space
	var advanced_target = player.global_position + home_local_pos
	advanced_target.x += current_lead_x
	advanced_target.y += current_pan_y

	# 4. FINAL SMOOTHING
	# If you still feel "lag", increase follow_speed (e.g. to 10.0 or 15.0)
	global_position = global_position.lerp(advanced_target, follow_speed * delta)

func handle_vertical_look(delta: float) -> void:
	var v_input = Input.get_axis("up", "down")
	var is_moving_horizontally = abs(player.velocity.x) > 100.0
	
	# Only pan if standing still or moving slowly
	if v_input != 0 and player.is_on_floor() and not is_moving_horizontally:
		look_timer += delta
		if look_timer >= look_delay:
			current_pan_y += v_input * pan_speed * delta
	else:
		look_timer = 0
		current_pan_y = move_toward(current_pan_y, 0, pan_speed * delta)
	
	current_pan_y = clamp(current_pan_y, -max_pan_up, max_pan_down)
