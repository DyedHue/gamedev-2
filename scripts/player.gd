extends CharacterBody2D

# --- Enums ---
enum HorizontalState { NONE, WALK, RUN }
enum VerticalState { NONE, GROUND_JUMP, RUN_JUMP, AIR_JUMP, WALL_JUMP, FALL, FLOATING }
enum AbilityState { NONE, DASH }

# --- Helper Classes ---
class PlayerState:
	var horizontal: HorizontalState = HorizontalState.NONE
	var vertical: VerticalState = VerticalState.NONE
	var ability: AbilityState = AbilityState.NONE
	
	var is_airborne: bool = false
	var is_wall_sliding: bool = false

	# Computed properties (Functions in GDScript)
	func is_jumping() -> bool:
		return vertical == VerticalState.GROUND_JUMP or vertical == VerticalState.AIR_JUMP
	
	func is_moving() -> bool:
		return horizontal == HorizontalState.WALK or horizontal == HorizontalState.RUN

class HasAbility:
	var dash: bool = false
	var wall_slide: bool = false
	var faydown_cloak: bool = false

# --- Main Script ---

var state: PlayerState = PlayerState.new()
var has_ability: HasAbility = HasAbility.new()

@export var WALK_SPEED: float = 300.0
@export var RUN_SPEED: float = 600.0
@export var JUMP_VELOCITY: float = -550.0
@export var WALL_JUMP_SPEED: float = 700.0
@export var GRAVITY = 2800

const MAX_JUMP_DURATION: float = 0.25
const MAX_AIR_JUMP_DURATION: float = 0.2
const MAX_WALL_JUMP_DURATION: float = 0.15
const MAX_WALL_JUMP_BACK_DUR: float = 0.15

const MAX_AIR_JUMP_CHARGE: int = 1
var air_jump_charge: int

var jump_duration: float = 0.0
var wall_jump_duration: float = 0.0
var wall_jump_back_dur: float = 0.0

var debug_info: String = ""
var frame_count: int = 0



func _ready() -> void:
	air_jump_charge = MAX_AIR_JUMP_CHARGE
	has_ability.wall_slide = true
	has_ability.dash = true

func _physics_process(delta: float) -> void:
	var gravity_vec: Vector2 = handle_gravity(delta)
	var movement_vec: Vector2 = handle_movement()
	var jump_vec: Vector2 = handle_jump(delta)
	var run_jump_vec: Vector2 = handle_run_jump(delta)
	var wall_jump_vec: Vector2 = handle_wall_jump()
	
	var current_velocity: Vector2 = Vector2.ZERO
	
	current_velocity.y += gravity_vec.y
	current_velocity.x += movement_vec.x
	
	if jump_vec != Vector2.ZERO:
		current_velocity.y = jump_vec.y
		
	if run_jump_vec != Vector2.ZERO:
		current_velocity = run_jump_vec
		
	if wall_jump_vec != Vector2.ZERO:
		current_velocity.x = wall_jump_vec.x
		current_velocity.y = wall_jump_vec.y

	current_velocity = pre_update_state(delta, current_velocity)
	
	velocity = current_velocity
	move_and_slide()
	
	post_update_state()
	
	show_debug()
	frame_count += 1

func show_debug() -> void:
	var slide_str = "sliding" if state.is_wall_sliding else "notSlid"
	
	var new_debug_info = "%f, %f %s    ⌚: %f\n     🧗⌚: %f  H:%s  V:%s  🔋: %d\n" % [
		velocity.x, 
		velocity.y, 
		slide_str, 
		jump_duration,
		wall_jump_duration, 
		HorizontalState.keys()[state.horizontal], 
		VerticalState.keys()[state.vertical], 
		air_jump_charge
	]

	if new_debug_info != debug_info:
		print("%d: %s" % [frame_count, new_debug_info])
	
	debug_info = new_debug_info

func handle_gravity(delta: float) -> Vector2:
	var gravity_vec = Vector2.ZERO
	var current_gravity = GRAVITY
	
	if state.is_wall_sliding and state.vertical == VerticalState.FALL:
		current_gravity /= 6.0
		
	if not is_on_floor():
		gravity_vec.y = velocity.y + current_gravity * delta
		
	return gravity_vec

func handle_movement() -> Vector2:
	var move_vec = Vector2.ZERO
	var cur_speed = WALK_SPEED
	var running = false
	
	if Input.is_action_pressed("dash") and has_ability.dash and is_on_floor():
		cur_speed = RUN_SPEED
		running = true
		
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		move_vec.x = direction * cur_speed
		state.horizontal = HorizontalState.RUN if running else HorizontalState.WALK
		
	return move_vec

func handle_jump(delta: float) -> Vector2:
	var jump_vec = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_vec.y = JUMP_VELOCITY
			state.vertical = VerticalState.GROUND_JUMP
		elif state.is_airborne:
			if air_jump_charge != 0:
				jump_vec.y = JUMP_VELOCITY
				state.vertical = VerticalState.AIR_JUMP
				air_jump_charge -= 1
				
	elif Input.is_action_pressed("jump"):
		if state.is_jumping():
			var limit = MAX_JUMP_DURATION if state.vertical == VerticalState.GROUND_JUMP else MAX_AIR_JUMP_DURATION
			if jump_duration < limit:
				jump_vec.y = JUMP_VELOCITY
				jump_duration += delta
				
	elif Input.is_action_just_released("jump"):
		jump_duration = 0.0
		
	return jump_vec

func handle_run_jump(delta: float) -> Vector2:
	var vec = Vector2.ZERO
	var direction = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		if state.horizontal == HorizontalState.RUN and is_on_floor():
			vec.y = JUMP_VELOCITY
			vec.x = RUN_SPEED * direction
			state.vertical = VerticalState.RUN_JUMP
			
	elif Input.is_action_pressed("jump"):
		if state.vertical == VerticalState.RUN_JUMP:
			if jump_duration < MAX_JUMP_DURATION:
				vec.y = JUMP_VELOCITY
				vec.x = RUN_SPEED
				jump_duration += delta
				
	elif Input.is_action_just_released("jump"):
		jump_duration = 0.0
		
	return vec

func handle_wall_jump() -> Vector2:
	var vec = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump"):
		if state.is_wall_sliding:
			state.vertical = VerticalState.WALL_JUMP
			vec = Vector2.UP * WALL_JUMP_SPEED
		
	return vec


func pre_update_state(_delta: float, temp_velocity: Vector2) -> Vector2:
	if is_on_wall() and not is_on_floor():
		if not state.is_wall_sliding and has_ability.wall_slide:
			temp_velocity.y = 0
			jump_duration = 0.0
			air_jump_charge = MAX_AIR_JUMP_CHARGE
			state.is_wall_sliding = true
			state.vertical = VerticalState.FALL
	
	return temp_velocity

func post_update_state() -> void:
	if state.is_wall_sliding:
		if not is_on_wall() or is_on_floor():
			state.is_wall_sliding = false
		else:
			wall_jump_duration = 0.0
			
	if is_on_floor():
		state.vertical = VerticalState.NONE
		air_jump_charge = MAX_AIR_JUMP_CHARGE
	elif velocity.y >= 0:
		state.vertical = VerticalState.FALL
		
	if state.vertical == VerticalState.FALL and is_on_floor():
		state.vertical = VerticalState.NONE
		
	if state.is_moving():
		if velocity.x == 0:
			state.horizontal = HorizontalState.NONE
			
	if not state.is_jumping():
		jump_duration = 0.0
		
	if not is_on_floor() and not is_on_wall():
		state.is_airborne = true
	else:
		state.is_airborne = false
