extends CharacterBody2D

@export var left = true
var factor = 1
var flipper_active = false  # Ensure a defined initial state

var intermediate_time = 0
var snap_time = .20
var snap_angle = 50
func _ready():
	factor = -1 if not left else 1
	HUD.clickable_input_event.connect(_on_clickable_input_event)
	if left:
		factor = -1
		#snap_angle = -abs(snap_angle)  # Ensure left flipper snap angle is negative
	else:
		factor = 1
		#snap_angle = abs(snap_angle)  # Ensure right flipper snap angle is positive


func _on_clickable_input_event(event, _input_position):
	if GameManager.get_game_enabled():
		flipper_active = event.pressed

func _physics_process(delta):
	if flipper_active:
		# Increment the time towards full extension
		intermediate_time = min(intermediate_time + delta, snap_time)
		# Apply rotation based on the proportion of snap_time elapsed
		set_rotation_degrees((intermediate_time / snap_time) * (snap_angle * factor))
	else:
		# Decrement the time back towards the rest position
		intermediate_time = max(intermediate_time - delta, 0)
		# Apply rotation in reverse based on the proportion of snap_time remaining
		set_rotation_degrees((intermediate_time / snap_time) * (snap_angle * factor))
