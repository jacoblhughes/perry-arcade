extends Node

# Export the NodePath to the player_initials scene
var config = ConfigFile.new()

var child_node_to_delete

@onready var main_node : Node

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
"1":{"title":"Perry Says","short_name":"perry_says","directions":"Smash Perry in the right order to get the high score!"}
,"2":{"title":"Python Perry","short_name":"perry_python","directions":"Make Perry eat the unfunny clown!"}
,"3":{"title":"Perry Water Polo","short_name":"perry_polo","directions":"Bounce Perry around to get the highscore!"}
,"4":{"title":"Perry's Llama Leap","short_name":"perry_llama","directions":"Perry stole your headband. Jump over his garbage as you chase him down!"}
,"5":{"title":"Perry Dodge","short_name":"perry_dodge","directions":"Help Perry avoid the zoo animals!"}
,"6":{"title":"Perry Flap","short_name":"perry_flap","directions":"Perry is trying to stop the bird from getting home. Help flappy!"}
,"7":{"title":"Perry Run","short_name":"perry_run","directions":"Get to the end of the maze as fast as you can and as many times as you can!"}
,"8":{"title":"Perry Space Attack","short_name":"perry_space","directions":"Roddy needs help avoiding the Vegaliens"}
,"9":{"title":"Perry Squash","short_name":"perry_squash","directions":"Help Perry squash"}
,"10":{"title":"Perry Putt","short_name":"perry_putt","directions":"Help Perry putt"}

}

var background_canvas_layer_instance

@onready var game_scene : Node = get_tree().get_root().get_node("Main")

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
	var new_initials = HUD.get_initials()
#	var item_list = $HighScorePopup/ColorRect/ItemList
	if high_scores_names.size() != high_scores.size():
		print("Error: Names and scores arrays have different sizes.")
		return

	var added = false 

	for i in range(high_scores.size()):
		if score > high_scores[i]:
			high_scores.insert(i, score)
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
		HUD.set_gameover_panel_congrats(true)
#	_replace_highscore_list()
	
func initiate_highscores_section():
	for key in games_list.keys():
		if not config.has_section(key):
			config.set_value(key,"scores",[0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
			config.set_value(key,"names",["JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH", "JLH"])
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
