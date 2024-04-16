extends CharacterBody2D

var force = 500
var target_position = Vector2(0,0)
var lerp_speed = 0.1
var is_touching = false 

var move_speed = 200
var stop_threshold = 10  # Stop moving when within 10 pixels of the target

# Called when the node enters the scene tree for the first time.
func _ready():

	target_position = %StartPosition.global_position
	get_parent().out_of_bounds.connect(_on_out_of_bounds)
	HUD.clickable_input_event.connect(_on_clickable_input_event)
	pass

func _on_clickable_input_event(event, input_position):
	
	if event.pressed:
		target_position = input_position
		if(GameManager.get_game_enabled()):
			is_touching=true
			target_position = input_position
		pass

func _physics_process(delta):

	if GameManager.get_game_enabled():
		var to_target = target_position - global_position
		var direction = to_target.normalized()
		if(direction.x<0):
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		var distance_to_target = to_target.length()
		if is_touching:
			if distance_to_target > stop_threshold:
				velocity = direction * move_speed
			else:
				velocity = Vector2.ZERO  # Stop moving if within threshold
				is_touching = false  # Optionally reset touching to require new input to move again

			# Move the character and slide along collisions
			move_and_slide()
		else:
			# Decelerate to a stop when not touching
			velocity = velocity.move_toward(Vector2.ZERO, move_speed * delta)
			move_and_slide()

func _on_out_of_bounds(reset_point):
	target_position=reset_point
