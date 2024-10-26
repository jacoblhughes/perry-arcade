extends CharacterBody2D

var reset_round = false


# Called when the node enters the scene tree for the first time.
var position_reset = false
var stored_position = Vector2(0,0)
var speed_increase = 0.0
var increased_velocity : Vector2 = Vector2.ZERO
var collision_cooldown: float = 1.0
var max_speed = 1000



func _ready():

#	_game_initialize()

	stored_position = position
	reset_round = true
	get_parent().position_reset.connect(_on_position_reset)
	HUD.clickable_input_event.connect(_on_clickable_input_event)
	pass # Replace with function body.



func _physics_process(delta):
	if(velocity.length() > max_speed):
		velocity = velocity.normalized() * max_speed
	if(velocity != Vector2(0,0)):
		$AnimatedSprite2D.play("moving")
	else:
		$AnimatedSprite2D.play("default")
	if collision_cooldown > 0:
		collision_cooldown -= delta

	if collision_cooldown<=0:
		var collision = move_and_collide(velocity * delta)
		if collision:
			var this_collision = collision.get_collider()
			AudioManager.play_sound("perry_polo_ball_hit")
			if this_collision.is_in_group("paddle"):

				var reflect_direction = collision.get_remainder().bounce((collision.get_normal()).normalized())
				velocity = velocity.bounce((collision.get_normal()).normalized())*speed_increase
				if(velocity.length() > max_speed):
					velocity = velocity.normalized() * max_speed
				move_and_collide(reflect_direction)

			else:
				var reflect_direction = collision.get_remainder().bounce(collision.get_normal())
				velocity = velocity.bounce(collision.get_normal())
				if(velocity.length() > max_speed):
					velocity = velocity.normalized() * max_speed
				move_and_collide(reflect_direction)

func _on_play_button_pressed():
	if reset_round:
		reset_round = false
	pass

func _on_reset_button_reset_button_pressed():
	position_reset = true

func _on_position_reset():

	_reset_ball()

func _on_clickable_input_event(event, _input_position):
	if(GameManager.get_game_enabled()):
		if event.pressed and reset_round:
			var swing_angle = randi_range (-45, 45)
			velocity = increased_velocity.rotated(deg_to_rad(swing_angle))
			reset_round = false

func _reset_ball():
	position_reset = true
	position = stored_position
	velocity = Vector2(0,0)
	position_reset = false
	reset_round = true
