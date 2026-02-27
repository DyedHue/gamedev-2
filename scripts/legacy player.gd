extends CharacterBody2D

enum HorizontalState { NONE, WALK, RUN }
enum VerticalState { NONE, JUMP, RUN_JUMP, AIR_JUMP, WALL_JUMP, FALL, FLOATING }

var hstate: HorizontalState = HorizontalState.NONE
var vstate: VerticalState = VerticalState.NONE

var is_airborne: bool = false
var is_wall_sliding: bool = false



class HasAbility:
	var dash: bool = false
	var wall_slide: bool = false
	var faydown_cloak: bool = false


@export var WALK_SPEED: float = 300.0
@export var RUN_SPEED: float = 600.0
@export var JUMP_VELOCITY: float = -400.0
@export var WALL_JUMP_SPEED: float = 500.0

@export var MAX_JUMP_DURATION: float = 0.25
@export var MAX_AIR_JUMP_DURATION: float = 0.2
@export var MAX_WALL_JUMP_DURATION: float = 0.15
@export var MAX_WALL_JUMP_BACK_DUR: float = 0.15
@export var MAX_AIR_JUMP_CHARGE: int = 1
@export var GRAVITY: float = 2300

var air_jump_charge: int
var jump_duration: float = 0.0
var wall_jump_duration: float = 0.0
var wall_jump_back_dur: float = 0.0

var has_ability: HasAbility = HasAbility.new()

var current_velocity: Vector2


func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	var gravity_vec: Vector2 = handle_gravity(delta)
	var movement_vec: Vector2 = handle_movement()
	var jump_vec: Vector2 = handle_jump(delta)
	#var wall_jump_vec: Vector2 = handle_wall_jump(delta)

	current_velocity = Vector2.ZERO

	# additive velocity
	current_velocity.y += gravity_vec.y
	current_velocity.x += movement_vec.x

	#overrides
	if jump_vec != Vector2.ZERO:
		current_velocity.y = jump_vec.y
	
		
	# if wall_jump_vec != Vector2.ZERO:
	# 	current_velocity.x = wall_jump_vec.x
	# 	current_velocity.y = wall_jump_vec.y

	pre_update_state(delta)

	velocity = current_velocity
	move_and_slide()
	post_update_state()
	show_debug()


func handle_gravity(delta: float) -> Vector2:
	var gravity_vec = Vector2.ZERO
	
	var current_gravity = GRAVITY
	
	if is_wall_sliding and vstate == VerticalState.FALL:
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
		hstate = HorizontalState.RUN if running else HorizontalState.WALK
		
	return move_vec

func handle_jump(delta: float) -> Vector2:
	var jump_vec = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_vec.y = JUMP_VELOCITY
			vstate = VerticalState.JUMP
				
	elif Input.is_action_pressed("jump"):
		if vstate == VerticalState.JUMP:
			if jump_duration < MAX_JUMP_DURATION:
				jump_vec.y = JUMP_VELOCITY
				jump_duration += delta
				
	elif Input.is_action_just_released("jump"):
		jump_duration = MAX_JUMP_DURATION
		
	return jump_vec


func handle_wall_jump(delta: float) -> Vector2:
	var vec = Vector2.ZERO
	var w_normal = get_wall_normal()
	
	if Input.is_action_just_pressed("jump"):
		if is_wall_sliding:
			vstate = VerticalState.WALL_JUMP
			vec = (w_normal + Vector2.UP) * WALL_JUMP_SPEED
			
	elif Input.is_action_pressed("jump"):
		if vstate == VerticalState.WALL_JUMP:
			if wall_jump_duration < MAX_WALL_JUMP_DURATION:
				vec = (w_normal + Vector2.UP) * WALL_JUMP_SPEED
				wall_jump_duration += delta
			elif not is_wall_sliding and wall_jump_back_dur < MAX_WALL_JUMP_BACK_DUR:
				var dir = Input.get_axis("move_left", "move_right")
				
				# Check if input is opposite to wall normal
				if dir == -w_normal.x:
					vec = (-w_normal + Vector2.UP) * WALL_JUMP_SPEED
				
				wall_jump_back_dur += delta

	elif Input.is_action_just_released("jump"):
		wall_jump_duration = 0.0
		wall_jump_back_dur = MAX_WALL_JUMP_BACK_DUR
		
	return vec

func pre_update_state(_delta: float):
	if is_on_wall() and not is_on_floor():
		if not is_wall_sliding and has_ability.wall_slide:
			current_velocity.y = 0
			jump_duration = 0.0
			air_jump_charge = MAX_AIR_JUMP_CHARGE
			is_wall_sliding = true
			vstate = VerticalState.FALL

func post_update_state() -> void:
	if is_wall_sliding:
		if not is_on_wall() or is_on_floor():
			is_wall_sliding = false
		else:
			wall_jump_duration = 0.0
			
	if is_on_floor():
		vstate = VerticalState.NONE
		air_jump_charge = MAX_AIR_JUMP_CHARGE
	elif velocity.y >= 0:
		vstate = VerticalState.FALL
		
	if vstate == VerticalState.FALL and is_on_floor():
		vstate = VerticalState.NONE
		
	if is_moving():
		if velocity.x == 0:
			hstate = HorizontalState.NONE
			
	if not vstate == VerticalState.JUMP:
		jump_duration = 0.0
		
	if not is_on_floor() and not is_on_wall():
		is_airborne = true
	else:
		is_airborne = false

func show_debug():
	print(velocity.x, "  ", velocity.y, "\n", VerticalState.keys()[vstate])

func is_moving() -> bool:
	return hstate == HorizontalState.WALK or hstate == HorizontalState.RUN
