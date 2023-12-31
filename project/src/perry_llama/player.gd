extends CharacterBody2D



var double_jump_counter = false
const JUMP_VELOCITY = -600.0
var rng = RandomNumberGenerator.new()
var animation_player: AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
signal dino_hit
func _ready():
	animation_player = $AnimatedSprite2D
	GameManager.in_play_area.connect(_on_in_play_area)
#func _input(event):
#		if event.is_action_pressed("left_mouse_click"):
#			velocity.y = JUMP_VELOCITY

func _on_in_play_area(_event):
	if(GameManager.get_game_enabled()):
		if Input.is_action_just_pressed("left_mouse_click") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_just_pressed("left_mouse_click") and not is_on_floor() and double_jump_counter  == false:
			velocity.y = JUMP_VELOCITY
			double_jump_counter = true
	pass

func _physics_process(delta):
	if not is_on_floor():
		animation_player.play("jumping")
		velocity.y += gravity * delta
		
	if is_on_floor():
		animation_player.play("default")  # Start the "jumping" animation
		double_jump_counter = false

	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)

		if("Enemy" in collision.get_collider().name):

			collision.get_collider().queue_free()

			dino_hit.emit()



















#DO NOT DELETE
#extends CharacterBody2D
#
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -600.0
#var animation_player: AnimatedSprite2D
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#signal dino_hit
#func _ready():
#	animation_player = $AnimatedSprite2D
#
##func _input(event):
##		if event.is_action_pressed("left_mouse_click"):
##			velocity.y = JUMP_VELOCITY
#
#func _physics_process(delta):
#	if(GameManager.get_game_enabled()):
#
#		if not is_on_floor():
#			animation_player.play("jumping")
#			velocity.y += gravity * delta
#
#		if is_on_floor():
#			animation_player.play("default")  # Start the "jumping" animation
#
#
#		# Handle Jump.
#		if Input.is_action_just_pressed("left_mouse_click") and is_on_floor():
#			velocity.y = JUMP_VELOCITY
#
##	if direction and direction == -1 :
##		velocity.x = direction * SPEED
###		animation_player.play("walking")  # Start the "jumping" animation
##		animation_player.flip_h=true
##	elif direction and direction == 1 :
##		velocity.x = direction * SPEED
###		animation_player.play("walking")  # Start the "jumping" animation
##		animation_player.flip_h=false
##
##	else:
##		velocity.x = move_toward(velocity.x, 0, SPEED)
#
#	move_and_slide()
#	for i in range(get_slide_collision_count()):
#		var collision = get_slide_collision(i)
#
#		if("Enemy" in collision.get_collider().name):
#			self.collision_mask = 0  # This will disable the player's ability to detect enemies (or anything else, for that matter).
#			collision.get_collider().queue_free()
#			print('game_over')
#			dino_hit.emit()
