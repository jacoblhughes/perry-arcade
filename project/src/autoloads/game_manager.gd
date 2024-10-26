extends Node

# Export the NodePath to the player_initials scene
var config = ConfigFile.new()

var child_node_to_delete

var perry_arcade_path = "user://perry_arcade.cfg"
var game_enabled = false
var current_game_scene : PackedScene

const DEFAULT_FLOAT = -1.0
const DEFAULT_TEXT = "-1"
const DEFAULT_BOOL = null

var current_initials

signal highscoreButtonpressed
signal initialsUpdated

var game_key = "JLH"

var games_list : Dictionary = {
"1":
	{"title":"Perry Says",
"short_name":"perry_says",
"objective":"Smash Perry in the face to get the high score!",
"directions":"Click on the buttons in the correct order",
"score_type":"value"
}
,"2":
	{"title":"Perry Python",
"short_name":"perry_python",
"objective":"Make Perry eat the unfunny mouse!",
"directions":"Turn Perry by clicking above, below, left, or right of the character",
"score_type":"value"
}
,"3":
	{"title":"Perry Water Polo",
"short_name":"perry_polo",
"objective":"Bounce Perry past your enemy!",
"directions":"Click above or below to protect your side and shoot Perry into the enemy side!",
"score_type":"value"
}
,"4":
	{"title":"Perry's Llama Leap",
"short_name":"perry_llama",
"objective":"Perry stole your headband. Jump over his garbage as you chase him down!",
"directions":"Click to make the llama jump or double jump!",
"score_type":"value"
}
,"5":
	{"title":"Perry Dodge",
"short_name":"perry_dodge",
"objective":"Help Perry avoid the zoo animals!",
"directions":"Click on the sceen to help Perry escape the charging animals",
"score_type":"value"
}
,"6":
	{"title":"Perry Flap",
"short_name":"perry_flap",
"objective":"Perry is trying to stop the bird from getting home. Help flappy!",
"directions":"Click to keep Flappy Perry up, stop clicking to let it fall",
"score_type":"value"
}
,"7":
	{"title":"Perry Run",
"short_name":"perry_run",
"objective":"Keep jumping and running to avoice obstacles",
"directions":"Click to make Perry jump from platform to platform",
"score_type":"value"
}
,"8":
	{"title":"Perry Space Attack",
"short_name":"perry_space",
"objective":"Help Perry stop the invading Vegaliens",
"directions":"Click to move the character. Avoid being hit or letting the enemies past you",
"score_type":"value"
}
,"9":
	{"title":"Perry Squash",
"short_name":"perry_squash",
"objective":"Help Perry squash",
"directions":"Click to squash the enemies. Avoid the red snakes",
"score_type":"value"
}
,"10":
	{"title":"Perry Putt",
"short_name":"perry_putt",
"objective":"Help Perry putt",
"directions":"Click the direction, then use the power meter button to determine the hit strength",
"score_type":"time"
}
,"11":
	{"title":"Perry Skeeball",
"short_name":"perry_skeeball",
"objective":"Help roll Perry into the goals",
"directions":"Click to shoot the ball in the direction of the arrow. Higher zones are worth more",
"score_type":"value"
}
,"12":
	{"title":"Perry Pinball",
"short_name":"perry_pinball",
"objective":"Bonk Perry against the mushrooms so he relaxes",
"directions":"Click to keep the ball up and hit the bumpers to get a score. Keep the ball from falling below the flippers.",
"score_type":"value"
}
,"13":
	{"title":"Perry Tamagotchi",
"short_name":"perry_tamagotchi",
"objective":"Watch over your own Perry",
"directions":"Keep Perry happy and healthy!",
"score_type":"value"
}
,"14":
	{"title":"Perry Memory",
"short_name":"perry_memory",
"objective":"Watch over your own Perry",
"directions":"Keep Perry happy and healthy!",
"score_type":"time"
}
}

var background_canvas_layer_instance

func _ready():

	var file_exists = FileAccess.file_exists(perry_arcade_path)
	if(!file_exists):

		var file = FileAccess.open(perry_arcade_path, FileAccess.WRITE_READ)
		file.store_string("[main]\n")
		file.store_string("\n")
		file.store_string("initials=\"JLH\"\n")
		file.store_string("\n")
		file.store_string("[background_music]\n")
		file.store_string("\n")
		file.store_string("value=1\n")
		file.store_string("playing=0\n")
		file.store_string("\n")
		file.store_string("[game_music]\n")
		file.store_string("\n")
		file.store_string("value=1\n")
		file.store_string("playing=0\n")
		file.close()
		config.load(perry_arcade_path)
	else:
		config.load(perry_arcade_path)
		if config.get_value("main", "initials",DEFAULT_TEXT) != DEFAULT_TEXT:
			pass
		else:
			config.set_value("main", "initials","JLH")
			config.save(perry_arcade_path)

		if config.get_value("background_music", "value", DEFAULT_FLOAT) != DEFAULT_FLOAT:
			pass
		else:
			config.set_value("background_music", "value",0.5)
			config.save(perry_arcade_path)

		if config.get_value("background_music", "playing", DEFAULT_BOOL) != DEFAULT_BOOL:
			pass
		else:
			config.set_value("background_music", "playing",0)
			config.save(perry_arcade_path)

		if config.get_value("game_music", "value", DEFAULT_FLOAT) != DEFAULT_FLOAT:
			pass
		else:
			config.set_value("game_music", "value",0.5)
			config.save(perry_arcade_path)

		if config.get_value("game_music", "playing", DEFAULT_BOOL) != DEFAULT_BOOL:
			pass
		else:
			config.set_value("game_music", "playing",0)
			config.save(perry_arcade_path)

	var new_initials = config.get_value("main", "initials")
	current_initials = new_initials
	initiate_highscores_section()
	HUD.update_initials(new_initials)
	AudioManager.update_background_music(config.get_value("background_music", "value", DEFAULT_FLOAT))
	AudioManager.set_background_music_mute(config.get_value("background_music", "playing", DEFAULT_FLOAT))
	AudioManager.update_game_music(config.get_value("game_music", "value", DEFAULT_FLOAT))
	AudioManager.set_game_music_mute(config.get_value("game_music", "playing", DEFAULT_FLOAT))

func get_games_list():
	return games_list

func get_config_path_file():
	return perry_arcade_path

func save_initials(initials):
	HUD.update_initials(initials)
	current_initials = initials
	config.set_value("main", "initials",current_initials)
	config.save(perry_arcade_path)

func return_initials():
	return current_initials

func check_highscore_and_rank():
	var high_scores_names = config.get_value(game_key, "names", [])
	var high_scores = config.get_value(game_key, "scores", [])
	var score = HUD.return_score()
	var seconds_passed = HUD.return_seconds_passed()
	var new_initials = HUD.return_initials()
	var score_type = games_list[game_key]['score_type']

#	var item_list = $HighScorePopup/ColorRect/ItemList
	if high_scores_names.size() != high_scores.size():
		print("Error: Names and scores arrays have different sizes.")
		return

	var added = false

	for i in range(high_scores.size()):
		if score_type == 'value':
			if score > high_scores[i]:
				high_scores.insert(i, score)
				high_scores_names.insert(i, new_initials)
				added = true
				break
		elif score_type == 'time':
			if seconds_passed < high_scores[i] or high_scores[i] == 0:

				high_scores.insert(i, seconds_passed)
				high_scores_names.insert(i, new_initials)
				added = true
				break
				
	if not added and high_scores.size() < 10:
		high_scores.append(score)
		high_scores_names.append(new_initials)

	while high_scores.size() > 10:
		high_scores.remove_at(high_scores.size() - 1)
		high_scores_names.remove_at(high_scores_names.size() - 1)

	config.save(perry_arcade_path)


	if(added):
		GameStartGameOver.set_gameover_panel_congrats(true)
#	_replace_highscore_list()

func initiate_highscores_section():
	for key in games_list.keys():
		if not config.has_section(key):
			config.set_value(key,"scores",[0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
			config.set_value(key,"names",["JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH"])
		if key == "13":
			if !config.has_section_key(key,"living") or typeof(config.get_value(key,"living")) != 1:
				config.set_value(key, "living",false)
			if !config.has_section_key(key,"hatch_time") or typeof(config.get_value(key,"hatch_time")) != 27:
				config.set_value(key, "hatch_time", {})
			if !config.has_section_key(key,"health") or (typeof(config.get_value(key,"health")) != 2 and typeof(config.get_value(key,"health")) != 3):
				config.set_value(key, "health", 100)
			if !config.has_section_key(key,"hunger") or (typeof(config.get_value(key,"hunger")) != 2 and typeof(config.get_value(key,"hunger")) != 3):
				config.set_value(key, "hunger", 100)
			if !config.has_section_key(key,"happiness") or (typeof(config.get_value(key,"happiness")) != 2 and typeof(config.get_value(key,"happiness")) != 3):
				config.set_value(key, "happiness", 100)
			if !config.has_section_key(key,"last_hunger_satisfy") or typeof(config.get_value(key,"last_hunger_satisfy")) != 27:
				config.set_value(key, "last_hunger_satisfy", {})
			if !config.has_section_key(key,"last_health_satisfy") or typeof(config.get_value(key,"last_health_satisfy")) != 27:
				config.set_value(key, "last_health_satisfy", {})
			if !config.has_section_key(key,"last_happiness_satisfy") or typeof(config.get_value(key,"last_happiness_satisfy")) != 27:
				config.set_value(key, "last_happiness_satisfy", {})
			config.save(perry_arcade_path)

func get_highscore_scores(key):

	var scores = config.get_value(key,"scores", [])

	return scores

func get_highscore_names(key):

	var names = config.get_value(key,"names", [])
	return names

func set_current_game_scene(scene):
	current_game_scene = scene

func get_current_game_scene():
	return current_game_scene

func get_game_list_values(key):
	return games_list[key]

func get_game_enabled():
	return game_enabled

func set_game_enabled(status):
	game_enabled = status

func set_game_key(key):
	game_key = key

func reset_high_scores():
	for key in games_list.keys():
		config.set_value(key, "scores", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
		config.set_value(key, "names", ["JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH"])
		if key == "13":
			config.set_value(key, "living",false)
			config.set_value(key, "hatch_time", {})
			config.set_value(key, "health", 100)
			config.set_value(key, "hunger", 100)
			config.set_value(key, "happiness", 100)
			config.set_value(key, "last_hunger_satisfy", {})
			config.set_value(key, "last_health_satisfy", {})
			config.set_value(key, "last_happiness_satisfy", {})
		config.save(perry_arcade_path)

func save_background_music_choice(value):
	config.set_value("background_music","playing",value)
	config.save(perry_arcade_path)

func save_game_effects_choice(game_effects_playing):
	config.set_value("game_music","playing",game_effects_playing)
	config.save(perry_arcade_path)

func save_background_music_value(value):
	config.set_value("background_music","value",value)
	config.save(perry_arcade_path)

func save_game_effects_value(value):
	config.set_value("game_music","value",value)
	config.save(perry_arcade_path)

#func save_perry_tamagotchi_status(status):
	#var save_key = "13"
	#config.set_value(save_key, "living", status.get("living", false))
	#config.set_value(save_key, "hatch_time", status.get("hatch_time", 0))
	#config.set_value(save_key, "health", status.get("health", 100))
	#config.set_value(save_key, "hunger", status.get("hunger", 100))
	#config.set_value(save_key, "happiness", status.get("happiness", 100))
	#config.set_value(save_key, "last_hunger_satisfy", status.get("last_hunger_satisfy", 0))
	#config.set_value(save_key, "last_health_satisfy", status.get("last_health_satisfy", 0))
	#config.save(perry_arcade_path)

func save_perry_tamagotchi_status(status):

	var save_key = "13"
	config.set_value(save_key, "living", status.get("living", false))
	# Format float values as strings to prevent scientific notation
	config.set_value(save_key, "hatch_time", status.get("hatch_time", {}))
	config.set_value(save_key, "health", status.get("health", 100))
	config.set_value(save_key, "hunger", status.get("hunger", 100))
	config.set_value(save_key, "happiness", status.get("happiness", 100))
	config.set_value(save_key, "last_hunger_satisfy", status.get("last_hunger_satisfy", {}))
	config.set_value(save_key, "last_health_satisfy", status.get("last_health_satisfy", {}))
	config.set_value(save_key, "last_happiness_satisfy", status.get("last_happiness_satisfy", {}))
	config.save(perry_arcade_path)


func load_perry_tamagotchi_status():
	var save_key = "13"
	var status = {
		"living": config.get_value(save_key, "living", false),
		"hatch_time": config.get_value(save_key, "hatch_time",  {}),
		"health": config.get_value(save_key, "health", 100),
		"hunger": config.get_value(save_key, "hunger", 100),
		"happiness": config.get_value(save_key, "happiness", 100),
		"last_hunger_satisfy": config.get_value(save_key, "last_hunger_satisfy",  {}),
		"last_health_satisfy": config.get_value(save_key, "last_health_satisfy",  {}),
		"last_happiness_satisfy": config.get_value(save_key, "last_happiness_satisfy",  {}),
	}
	return status
