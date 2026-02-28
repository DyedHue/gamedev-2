extends CharacterBody2D

var pick1
var pick2
var pick1col 
var pick2col
var attack: bool
# --- Enums ---
enum HorizontalState { NONE, WALK, RUN }
enum VerticalState { NONE, GROUND_JUMP, RUN_JUMP, AIR_JUMP, WALL_JUMP, FALL, FLOATING }
enum AbilityState { NONE, DASH }

# --- Helper Classes ---
class PlayerState:
	var horizontal: HorizontalState = HorizontalState.NONE
	var vertical: VerticalState = VerticalState.NONE
	var ability: AbilityState = AbilityState.NONE
	
	var is_wall_sliding: bool = false
	
	func is_moving() -> bool:
		return horizontal == HorizontalState.WALK or horizontal == HorizontalState.RUN


@export var can_dash: bool = false
@export var can_wall_slide: bool = false
@export var can_variable_jump: bool = false
var has_pickaxe: bool=false
# --- Main Script ---

var state: PlayerState = PlayerState.new()

@export var WALK_SPEED: float = 400.0
@export var RUN_SPEED: float = 700.0
@export var JUMP_VELOCITY: float = -650.0
@export var WALL_JUMP_SPEED: float = 700.0
@export var GRAVITY: float = 2800.0

const MAX_JUMP_DURATION: float = 0.25
const MAX_WALL_JUMP_DURATION: float = 0.15
const MAX_WALL_JUMP_BACK_DUR: float = 0.15

const MAX_AIR_JUMP_CHARGE: int = 0
var air_jump_charge: int

var jump_duration: float = 0.0
var wall_jump_duration: float = 0.0
var wall_jump_back_dur: float = 0.0

var debug_info: String = ""
var frame_count: int = 0

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	air_jump_charge = MAX_AIR_JUMP_CHARGE
	#can_wall_slide = true
	can_dash = true
	pick1=$AnimatedSprite2D/pickaxe
	pick2= $AnimatedSprite2D/pickaxe2
	pick1col =$AnimatedSprite2D/pickaxe/myhitbox/CollisionShape2D
	pick2col= $AnimatedSprite2D/pickaxe2/myhitbox/CollisionShape2D
	pick1col.disabled=false
	pick1.hide()
	pick2.hide()
	pick2col.disabled=true
	attack=0
	

func _physics_process(delta: float) -> void:
	can_wall_slide=$"../hook pickup".has_hook
	has_pickaxe=$"../pickaxe pickup".has_pickaxe
	can_variable_jump=$"../boot_pickup".has_boots
	var gravity_vec: Vector2 = handle_gravity(delta)
	var movement_vec: Vector2 = handle_movement()
	var jump_vec: Vector2 = handle_jump(delta)
	var wall_jump_vec: Vector2 = handle_wall_jump()
	
	var current_velocity: Vector2 = Vector2.ZERO
	
	current_velocity.y += gravity_vec.y
	current_velocity.x += movement_vec.x

	if jump_vec != Vector2.ZERO:
		current_velocity.y = jump_vec.y	
		
		
	if wall_jump_vec != Vector2.ZERO:
		current_velocity.y = wall_jump_vec.y

	if Input.is_action_pressed("move_left"):
		pick1.hide()
		if has_pickaxe:
			pick2.show()
	elif Input.is_action_pressed("move_right"):
		#pick1col.disabled=false
		if has_pickaxe:
			pick1.show()
		pick2.hide()
		#pick2col.disabled=false
	
	# Rest of your movement code...
	velocity = current_velocity
	move_and_slide()
	post_update_state()
	
	show_debug()
	frame_count += 1



func handle_gravity(delta: float) -> Vector2:
	var gravity_vec = Vector2.ZERO
	var current_gravity = GRAVITY
	
	if is_on_wall() && !is_on_floor() and state.vertical == VerticalState.FALL:
		current_gravity /= 6.0
		
	if not is_on_floor():
		gravity_vec.y = velocity.y + current_gravity * delta
		
	return gravity_vec

func handle_movement() -> Vector2:
	var move_vec = Vector2.ZERO
	var cur_speed = WALK_SPEED
	var running = false
	
	if Input.is_action_pressed("dash") and can_dash and is_on_floor():
		cur_speed = RUN_SPEED
		running = true
		
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		move_vec.x = direction * cur_speed
		state.horizontal = HorizontalState.RUN if running else HorizontalState.WALK
	else:
		state.horizontal = HorizontalState.NONE

	return move_vec

func handle_jump(delta: float) -> Vector2:
	var jump_vec = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_vec.y = JUMP_VELOCITY
			state.vertical = VerticalState.GROUND_JUMP
				
	elif Input.is_action_pressed("jump") and can_variable_jump:
		if state.vertical == VerticalState.GROUND_JUMP:
			if jump_duration < MAX_JUMP_DURATION:
				jump_vec.y = JUMP_VELOCITY
				jump_duration += delta
			else:
				state.vertical = VerticalState.NONE
				jump_duration = 0
	elif Input.is_action_just_released("jump"):
		state.vertical = VerticalState.NONE
		
	return jump_vec

func handle_wall_jump() -> Vector2:
	var vec = Vector2.ZERO
	if(!can_wall_slide):
		return vec
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() && !is_on_floor():
			state.vertical = VerticalState.WALL_JUMP
			vec = Vector2.UP * WALL_JUMP_SPEED
		
	return vec

func post_update_state() -> void:
	if is_on_floor():
		jump_duration = 0
	elif velocity.y >= 0:
		state.vertical = VerticalState.FALL
		
	if state.vertical == VerticalState.FALL and is_on_floor():
		state.vertical = VerticalState.NONE

func show_debug() -> void:
	var slide_str = "sliding" if state.is_wall_sliding else "notSlid"
	
	var new_debug_info = "%f, %f %s    ⌚: %f\n     🧗⌚: %f  H:%s  V:%s  🔋: %d floor: %s wall: %s\n" % [
		velocity.x, 
		velocity.y, 
		slide_str, 
		jump_duration,
		wall_jump_duration, 
		HorizontalState.keys()[state.horizontal], 
		VerticalState.keys()[state.vertical], 
		air_jump_charge,
		is_on_floor(),
		is_on_wall()
	]

	if new_debug_info != debug_info:
		print("%d: %s" % [frame_count, new_debug_info])
	
	debug_info = new_debug_info
