extends Area2D

@export var player: CharacterBody2D
@export var camera: Camera2D

@export var gameover: bool = false
@export var freeze_duration: float = 5.0
@export var game_over_cam_pos: Vector2 = Vector2(9429.0, 178.0)
@export var game_over_zoom: Vector2 = Vector2(0.1, 0.1)

var waiting_for_input: bool = false

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(_other_area):
	if gameover: return
	
	hide()
	gameover = true
	if has_node("CollisionShape2D"):
		$CollisionShape2D.queue_free()
	start_game_over_sequence()

func start_game_over_sequence():
	if is_instance_valid(player) and "is_frozen" in player:
		player.is_frozen = true
	
	if is_instance_valid(camera) and camera.has_method("start_game_over_cam"):
		camera.start_game_over_cam(game_over_cam_pos, game_over_zoom, 1)
	
	await get_tree().create_timer(freeze_duration).timeout
	
	waiting_for_input = true

func _process(_delta: float) -> void:
	if waiting_for_input:
		if Input.is_action_just_pressed("move_left") or \
		   Input.is_action_just_pressed("move_right") or \
		   Input.is_action_just_pressed("jump") or \
		   Input.is_action_just_pressed("dash"):
			
			resume_game()

func resume_game():
	waiting_for_input = false
	gameover = false
	
	if is_instance_valid(player) and "is_frozen" in player:
		player.is_frozen = false
		
	if is_instance_valid(camera) and camera.has_method("end_game_over_cam"):
		camera.end_game_over_cam()
