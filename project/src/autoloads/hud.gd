extends CanvasLayer

var child_node_to_delete
var start_time_timer_used = false
var game_time_left_timer_used = false
var start_timer_countdown = false
var game_time_left_timing = false
var game_time_passed_timer_used = false
var score = 0
var lives  = 0
var level = 0
var seconds_passed = 0

var initial_score_value : int
var score_advance_base_value : int
var initial_lives_value : int
var lives_advance_base_value : int
var initial_level_value : int
var level_advance_check_value : int
var level_advance_base_value : int
var start_timer_countdown_value : int
var game_time_left_timer_value : int


var main_scene : Node

var previous_score = 0


signal hud_ready
@export var input_panel : Panel
signal start_timer_countdown_timeout
signal game_time_left_timer_timeout
signal clickable_input_event
signal advance_level
# Called when the node enters the scene tree for the first time.
func _ready():
	input_panel.input_event.connect(_on_clickable_input_event)
	call_deferred("get_main_scene")
	%GameTimePassedTimer.timeout.connect(_on_game_time_passed_timer_timeout)
	if %Input.visible:
		%Input.hide()
	pass

func get_main_scene():
	main_scene = get_tree().get_root().get_node("Main")


func _process(delta):

	if start_time_timer_used and start_timer_countdown:
		var countdown_timer_left = %StartCountdownTimer.time_left
		%Time.text = "%d:%02d" % [floor(countdown_timer_left / 60), int(countdown_timer_left) % 60]

	if game_time_left_timer_used and game_time_left_timing:
		var game_left_timer = %GameTimeLeftTimer.time_left
		%Time.text = "%d:%02d" % [floor(game_left_timer / 60), int(game_left_timer) % 60]
	pass

func update_initials(value):
	%Initials.text = value

func return_initials():
	return(%Initials.text)

func update_score(value = 1):
	var old_score = score
	var new_score = old_score + (value * 1)
	score = new_score
	var score_text = str(score)
	%Score.text = score_text
	check_advance_level()

func set_or_reset_score(value = 0):
	var new_score
	if value != 0:
		new_score = value
	else:
		new_score = 0
	score = new_score
	%Score.text = str(score)

	check_advance_level()

func return_score():
	return score

func return_seconds_passed():
	return seconds_passed

func home_button_pressed():
	_on_home_button_pressed()

func _on_home_button_pressed():

	clear_hud()
	GameStartGameOver.hide()
	GameManager.set_game_enabled(false)
	GameStartGameOver.set_gameover_panel(false)
	GameStartGameOver.set_gameover_panel_congrats(false)
	child_node_to_delete = main_scene.get_children()
	if child_node_to_delete:
		Buttons.visible = true
		for child in child_node_to_delete:
			child.queue_free()
	HUD.set_or_reset_level()
	Interruptions.stop_interruptions()
	print('stop interruptions')
	self.hide()

	pass # Replace with function body.

func set_or_reset_lives(default_lives = "INF"):
	if typeof(default_lives) == TYPE_INT:
		lives = default_lives
		%Lives.text = str(default_lives)
	else:
		lives=3
		%Lives.text = default_lives

func return_lives():
	return lives

func update_lives(value = -1):

	var old_lives = lives
	var new_lives = old_lives + (value * 1)
	lives = new_lives
	if lives <= 0:
		GameStartGameOver.out_of_lives()
	%Lives.text = str(lives)


func check_advance_level():
	if score > 0 and score >= previous_score:

		if (int(score) % level_advance_check_value) < (int(score) - int(previous_score)):
			previous_score = score
			var new_level = int(int(score) / int(level_advance_check_value))
			set_or_reset_level((level_advance_base_value * new_level) + initial_level_value)
			advance_level.emit()

func set_or_reset_level(default_level = "INF"):
	if typeof(default_level) == TYPE_INT:
		level = default_level
		%Level.text = str(level)
	else:
		%Level.text = default_level

#func update_game_level(value):
	#var old_level = level
	#var new_level = old_level + value
	#level = new_level
	#%Level.text = str(level)

func return_game_level():
	return level

func set_start_timer_countdown_and_start():
	start_time_timer_used = true
	start_timer_countdown = true
	%StartCountdownTimer.wait_time = start_timer_countdown_value
	%StartCountdownTimer.start()


func _on_start_timer_countdown_timeout():
	start_time_timer_used = false
	start_timer_countdown_timeout.emit()
	clear_timer()
	pass # Replace with function body.

func set_game_time_left_and_start():
	game_time_left_timer_used = true
	game_time_left_timing = true
	%GameTimeLeftTimer.wait_time = game_time_left_timer_value
	%GameTimeLeftTimer.start()

func add_time_to_game_time_left(value):
	var new_time_left = %GameTimeLeftTimer.time_left + value
	%GameTimeLeftTimer.stop()
	%GameTimeLeftTimer.wait_time = new_time_left
	%GameTimeLeftTimer.start()

func _on_game_left_timer_timeout():
	game_time_left_timer_used = false
	game_time_left_timer_timeout.emit()
	clear_timer()
	pass # Replace with function body.

func set_game_time_passed_timer_start():
	game_time_passed_timer_used = true
	%GameTimePassedTimer.start()

func _on_game_time_passed_timer_timeout():
	var new_seconds_passed = seconds_passed
	new_seconds_passed += 1
	seconds_passed = new_seconds_passed
	%Score.text = str(seconds_passed)
	pass


func clear_timer():
	%Time.text = "INF"

func clear_hud():
	set_or_reset_score()
	set_or_reset_lives()
	start_time_timer_used = false
	game_time_left_timer_used = false
	start_timer_countdown = false
	game_time_left_timing = false
	%Time.text = "INF"
	%StartCountdownTimer.stop()
	%StartCountdownTimer.wait_time = 3
	%GameTimeLeftTimer.stop()
	%GameTimeLeftTimer.wait_time = 60
	%GameTimePassedTimer.stop()
	%GameTimePassedTimer.wait_time = 1

#func _on_panel_gui_input(event):
#	if event is InputEventScreenTouch and not event.is_handled:
#		clickable_input_event.emit(event,event.position)
	pass # Replace with function body.

func _on_clickable_input_event(event):

	if event is InputEventScreenTouch:
		clickable_input_event.emit(event,event.position)

func get_play_area_position():
	return %InputPanel.global_position

func get_play_area_size():
	return %InputPanel.size



func hud_initialize(
	this_initial_score_value
, this_score_advance_base_value
, this_initial_lives_value
, this_lives_advance_base_value
, this_initial_level_value
,this_level_advance_check_value
, this_level_advance_value
, this_start_timer_countdown_callable
, this_start_timer_countdown_value
, this_game_time_left_timer_callable
, this_game_time_left_timer_value
, this_advance_level_callable
):
	initial_score_value = this_initial_score_value
	score_advance_base_value = this_score_advance_base_value
	initial_lives_value = this_initial_lives_value
	lives_advance_base_value = this_lives_advance_base_value
	initial_level_value = this_initial_level_value
	level_advance_check_value = this_level_advance_check_value
	level_advance_base_value = this_level_advance_value
	start_timer_countdown_value = this_start_timer_countdown_value
	game_time_left_timer_value = this_game_time_left_timer_value
	set_or_reset_score(initial_score_value)
	set_or_reset_lives(initial_lives_value)
	set_or_reset_level(initial_level_value)

	start_timer_countdown_timeout.connect(this_start_timer_countdown_callable)
	game_time_left_timer_timeout.connect(this_game_time_left_timer_callable)
	advance_level.connect(this_advance_level_callable)
