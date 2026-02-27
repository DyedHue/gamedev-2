extends CharacterBody2D

enum State { IDLE, MOVING, JUMPING, FALLING, WALL_SLIDING }
var state: State = State.IDLE

@export_group("Movement")
@export var WALK_SPEED: float = 300.0
@export var RUN_SPEED: float = 600.0
@export var GRAVITY: float = 2000.0

@export_group("Jump Settings")
@export var JUMP_VELOCITY: float = -550.0
@export var WALL_JUMP_UP_FORCE: float = -500.0   # Power of the climb
@export var WALL_STICK_FORCE: float = 150.0      # How hard we push INTO the wall
@export var WALL_SLIDE_FRICTION: float = 0.2     # 0.1 = very slow slide, 1.0 = normal gravity

@export_group("Abilities")
@export var CAN_DASH: bool = false
@export var CAN_WALL_SLIDE: bool = true

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	handle_jump()
	
	move_and_slide()
	update_state_machine()
	show_debug()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var current_gravity = GRAVITY
		
		# If sliding down a wall, slow down the fall
		if is_on_wall_only() and velocity.y > 0 and CAN_WALL_SLIDE:
			current_gravity *= WALL_SLIDE_FRICTION
			
		velocity.y += current_gravity * delta

func handle_horizontal_movement() -> void:
	var direction = Input.get_axis("move_left", "move_right")
	var speed = RUN_SPEED if (Input.is_action_pressed("dash") and CAN_DASH) else WALK_SPEED
	
	if direction:
		velocity.x = direction * speed
	else:
		# If we are on a wall, don't immediately kill X velocity 
		# so we stay "pressed" against it
		if not is_on_wall():
			velocity.x = move_toward(velocity.x, 0, speed)

func handle_jump() -> void:
	# 1. Standard Ground Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 2. Wall Climb Jump (The Vertical Jump)
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and CAN_WALL_SLIDE:
		var wall_normal = get_wall_normal()
		
		# Jump Upwards
		velocity.y = WALL_JUMP_UP_FORCE
		
		# Push INTO the wall (opposite of normal) to stay attached
		# wall_normal points away from the wall, so -wall_normal points into it
		velocity.x = -wall_normal.x * WALL_STICK_FORCE

	# Variable Jump Height (Release jump button to cut upward momentum)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func update_state_machine() -> void:
	if is_on_floor():
		state = State.MOVING if abs(velocity.x) > 10 else State.IDLE
	elif is_on_wall_only() and CAN_WALL_SLIDE:
		state = State.WALL_SLIDING
	else:
		state = State.JUMPING if velocity.y < 0 else State.FALLING

func show_debug() -> void:
	if Engine.get_physics_frames() % 15 == 0:
		print("State: ", State.keys()[state], " | Vel: ", var_to_str(velocity))
