extends CanvasLayer

@onready var pickaxe=$Pickaxe
@onready var jump_boot=$"Jump boot"
@onready var hook=$Hook
@onready var dash_boot=$"Dash Boot"
@onready var player=$"../Player"
# Called when the node enters the scene tree for the first time.
func unlock(sprite, yn):
	if yn:
		sprite.modulate=Color.WHITE
	else:
		sprite.modulate.a=0
	
func _ready() -> void:
	unlock(pickaxe, false)
	unlock(jump_boot, false)
	unlock(hook, false)
	unlock(dash_boot, false)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.has_pickaxe:
		unlock(pickaxe, true)
	if player.can_wall_slide:
		unlock(hook, true)
	if player.can_variable_jump:
		unlock(jump_boot, true)
	if player.can_dash:
		unlock(dash_boot, true)
	pass
