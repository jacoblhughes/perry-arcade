extends CharacterBody2D
class_name PerryRunPlayer

const JUMP_VELOCITY = -750.0
const MAX_JUMP_TIME = 0.2
var gravity = 1200
var jump_time = 0.0
var xpos
var should_jump

func _ready():
	HUD.clickable_input_event.connect(_on_clickable_input_event)
	pass

func _on_clickable_input_event(event, input_position):
	if event.is_pressed():
		should_jump = true
	else:
		should_jump = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Check both traditional input and the clickable event
	if should_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_time = 0  # Start counting jump time

	elif should_jump and not is_on_floor() and jump_time < MAX_JUMP_TIME:
		jump_time += delta
		velocity.y -= 35

	move_and_slide()
	position.x = clamp(position.x, xpos, xpos)  # Keep the player at xpos


func set_xpos(pos):
	xpos = pos
