extends Node2D

@export var status_hud : CanvasLayer
@export var player_scene : PackedScene
@export var egg_scene : PackedScene
@export var starting_marker : Marker2D
@export var tween_locations_node : Node2D
@export var hunger_satisfy_node : Node2D

var initial_score_value = 0
var score_advance_base_value = 1
var initial_lives_value = 1
var lives_advance_base_value = 1
var initial_level_value = 1
var level_advance_check_value = 10
var level_advance_base_value = 1
var start_timer_countdown_value = 3
var game_time_left_timer_value = 3

var living_status
var hatch_time
var health_status
var hunger_status
var happiness_status
var last_hunger_satisfy
var last_hunger_penalize


var hunger_penalize_seconds = 172800
var health_effected = false

signal player_to_eat

# Called when the node enters the scene tree for the first time.
func _ready():
	var start_button_callable = Callable(self, "_on_play_button_pressed")
	var game_over_callable = Callable(self,"_on_game_over")
	var start_timer_countdown_callable = Callable(self,"_on_start_timer_countdown_timeout")
	var game_time_left_timer_callable = Callable(self,"_on_game_time_left_timer_timeout")
	HUD.hud_initialize(initial_score_value,score_advance_base_value, initial_lives_value,lives_advance_base_value, initial_level_value,level_advance_check_value,level_advance_base_value,start_timer_countdown_callable,start_timer_countdown_value, game_time_left_timer_callable,game_time_left_timer_value)
	GameStartGameOver.game_start_game_over_initialize(start_button_callable,game_over_callable)
	Background.show()

	var xform = get_viewport_rect().size.x
	var yform = get_viewport_rect().size.y
	var xatio = xform/720
	var yatio = yform/1280
	print(xform , " " , yform)

	if yform > 1280:
		var nodes_to_move = []
		for node in nodes_to_move:
			node.position.y *= yatio
		var nodes_to_scale = []
		for node in nodes_to_scale:
			node.scale.y *= yatio

	if xform > 720:
		var nodes_to_move = []
		for node in nodes_to_move:
			node.position.x *= xatio
		var nodes_to_scale = []



	# Load the status from the GameManager
	var tamagotchi_status = GameManager.load_perry_tamagotchi_status()

	# Assign the loaded values to the variables
	living_status = tamagotchi_status.get("living", false)
	hatch_time = tamagotchi_status.get("hatch_time",  0)
	health_status = tamagotchi_status.get("health", 100)
	hunger_status = tamagotchi_status.get("hunger", 100)
	happiness_status = tamagotchi_status.get("happiness", 100)
	last_hunger_satisfy = tamagotchi_status.get("last_hunger_satisfy",  0)
	last_hunger_penalize = tamagotchi_status.get("last_hunger_penalize",  0)

	if hatch_time == {} or last_hunger_satisfy == {} or last_hunger_penalize == {}:
		living_status = false
		health_status = 100
		hunger_status = 100
		happiness_status = 100

	status_hud.set_status({
		"living": living_status,
		"hatch_time": hatch_time,
		"health": health_status,
		"hunger": hunger_status,
		"happiness": happiness_status,
		"last_hunger_satisfy": last_hunger_satisfy,
		"last_hunger_penalize": last_hunger_penalize
	})

	status_hud.hunger_satisfy.connect(_on_hunger_satisfy_button_pressed)

	if living_status:
		_initiate_player()
	else:
		var egg = egg_scene.instantiate()
		egg.position = starting_marker.position
		egg.egg_hatched.connect(_on_egg_hatched)
		add_child.call_deferred(egg)


	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if living_status and last_hunger_satisfy != {} and GameManager.get_game_enabled():
		_check_hunger()


	pass

func _on_play_button_pressed():
	GameManager.set_game_enabled(true)

func _on_egg_hatched():

	living_status = true
	var current_time = Time.get_unix_time_from_system()
	hatch_time = Time.get_datetime_dict_from_unix_time(current_time)
	last_hunger_satisfy = Time.get_datetime_dict_from_unix_time(current_time)
	last_hunger_penalize = Time.get_datetime_dict_from_unix_time(current_time)
	_initiate_player()
	status_hud.set_status({
		"living": living_status,
		"hatch_time": hatch_time,
		"health": health_status,
		"hunger": hunger_status,
		"happiness": happiness_status,
		"last_hunger_satisfy": last_hunger_satisfy,
		"last_hunger_penalize": last_hunger_penalize
	})
	GameManager.save_perry_tamagotchi_status({
		"living": living_status,
		"hatch_time": hatch_time,
		"health": health_status,
		"hunger": hunger_status,
		"happiness": happiness_status,
		"last_hunger_satisfy": last_hunger_satisfy,
		"last_hunger_penalize": last_hunger_penalize
	})



	pass

func _check_hunger():
	var current_time = Time.get_unix_time_from_system()
	var seconds_since_last_satisfy = current_time - Time.get_unix_time_from_datetime_dict(last_hunger_satisfy)
	var hunger_decrease = floor(seconds_since_last_satisfy / hunger_penalize_seconds)  # Calculate how much hunger should decrease

	# Update hunger status and apply health penalties if needed
	if hunger_decrease > 0:
		hunger_status = max(hunger_status - hunger_decrease, 0)  # Reduce hunger, prevent it from going below 0
		last_hunger_satisfy = Time.get_datetime_dict_from_unix_time(current_time)  # Reset last satisfy time

		# Check if hunger is depleted
		if hunger_status == 0:
			health_effected = true
			health_status -= 1  # Subtract some health if hunger reaches 0
			health_status = max(health_status, 0)  # Prevent health from dropping below 0
			last_hunger_penalize = Time.get_datetime_dict_from_unix_time(current_time)  # Update the last hunger penalize time
#
		## Update the HUD and save the game state

		status_hud.set_status({
			"living": living_status,
			"hatch_time": hatch_time,
			"health": health_status,
			"hunger": hunger_status,
			"happiness": happiness_status,
			"last_hunger_satisfy": last_hunger_satisfy,
			"last_hunger_penalize": last_hunger_penalize
		})
		GameManager.save_perry_tamagotchi_status({
			"living": living_status,
			"hatch_time": hatch_time,
			"health": health_status,
			"hunger": hunger_status,
			"happiness": happiness_status,
			"last_hunger_satisfy": last_hunger_satisfy,
			"last_hunger_penalize": last_hunger_penalize
		})

func _initiate_player():
	status_hud.show()
	var player = player_scene.instantiate()
	player.position = starting_marker.position
	player_to_eat.connect(Callable(player, "_on_player_to_eat"))
	player.player_eating.connect(Callable(hunger_satisfy_node, "play_eating_animation"))
	hunger_satisfy_node.hunger_satisfy_animation_finished.connect(Callable(player, "_on_player_finished_eating"))
	player.player_finished_eating.connect(Callable(status_hud,"_on_player_finished_eating"))
	player.player_finished_eating.connect(_on_player_hunger_satisfy)

	var location_markers = []
	location_markers.append(starting_marker.position)
	for node in tween_locations_node.get_children():
		location_markers.append(node.position)

	add_child.call_deferred(player)
	player.call_deferred("assign_tween_positions",location_markers)
	player.call_deferred("assign_hunger_satisfy_position",hunger_satisfy_node.position)

func _on_hunger_satisfy_button_pressed():
	player_to_eat.emit()
	pass

func _on_player_hunger_satisfy():
	var current_time = Time.get_unix_time_from_system()
	last_hunger_satisfy = Time.get_datetime_dict_from_unix_time(current_time)
	hunger_status = min(hunger_status + 20, 100)
	status_hud.set_status({
		"living": living_status,
		"hatch_time": hatch_time,
		"health": health_status,
		"hunger": hunger_status,
		"happiness": happiness_status,
		"last_hunger_satisfy": last_hunger_satisfy,
		"last_hunger_penalize": last_hunger_penalize
	})
	GameManager.save_perry_tamagotchi_status({
		"living": living_status,
		"hatch_time": hatch_time,
		"health": health_status,
		"hunger": hunger_status,
		"happiness": happiness_status,
		"last_hunger_satisfy": last_hunger_satisfy,
		"last_hunger_penalize": last_hunger_penalize
	})
