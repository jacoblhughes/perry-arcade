extends Node


#main
@export var main_applause : AudioStreamWAV
@export var main_game_over : AudioStreamWAV

@export var background_music : AudioStreamWAV
@export var background_music_2 : AudioStreamWAV


#perry_polo
@export var perry_polo_ball_hit : AudioStreamWAV
@export var perry_polo_whirlpool_sounds : Array[AudioStreamWAV]


var background_animation_player : AnimationPlayer = null
var background_player : AudioStreamPlayer = null
var background_player_2 : AudioStreamPlayer = null
# Export the NodePath to the player_initials scene

var background_playing : bool = false
var background_level : float = 0.0
var game_effects_playing : bool = false
var game_effects_level : float = 0.0

var buses = {"Game": 8} # Define the number of players for each bus

var available = {}  # Dictionary to hold available players for each bus
var queues = {}  # Dictionary to hold queues for each bus



# Called when the node enters the scene tree for the first time.
func _ready():
	var game_audio_node = Node.new()
	game_audio_node.name = "GameAudio"
	add_child(game_audio_node)

	var background_audio_node = Node.new()
	background_audio_node.name = "BackgroundAudio"
	add_child(background_audio_node)

	for bus in buses.keys():
		available[bus] = []
		queues[bus] = []
		for i in range(buses[bus]):
			var p = AudioStreamPlayer.new()
			game_audio_node.add_child(p)  # Add to the game audio parent node
			available[bus].append(p)
			p.connect("finished", Callable(self, "_on_stream_finished").bind(bus, p))
			p.name = "Game" + str(i + 1)
			p.bus = bus


	background_player = AudioStreamPlayer.new()
	background_player.name = "Background"
	background_audio_node.add_child(background_player)
	background_player.bus = "Background"
	background_player_2 = AudioStreamPlayer.new()
	background_player_2.name = "Background2"
	background_audio_node.add_child(background_player_2)
	background_player_2.bus = "Background"
	background_animation_player = AnimationPlayer.new()
	background_animation_player.name = "BackgroundAnimationPlayer"
	background_audio_node.add_child(background_animation_player)

func crossfade_to(audio_stream: AudioStream) -> void:
	# If both tracks are playing, we're calling the function in the middle of a fade.
	# We return early to avoid jumps in the sound.
	if background_player.playing and background_player_2.playing:
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	if background_player_2.playing:
		background_player.stream = audio_stream
		background_player.play()
		background_animation_player.play("FadeToTrack1")
	else:
		background_player_2.stream = audio_stream
		background_player_2.play()
		background_animation_player.play("FadeToTrack2")


func _on_stream_finished(bus, player):
	# When finished playing a stream, make the player available again.
	available[bus].append(player)

func play_sound(sound_name: String):
	match sound_name:
		"perry_polo_ball_hit":
			queues["Game"].append(perry_polo_ball_hit)
		"main_applause":
			queues["Game"].append(main_applause)
		"main_game_over":
			queues["Game"].append(main_game_over)
		"perry_polo_whirlpool_sounds":
			var selection = perry_polo_whirlpool_sounds[randi() % perry_polo_whirlpool_sounds.size()]
			queues["Game"].append(selection)
		_:
			print("Sound not recognized")


func _process(delta):
	for bus in queues.keys():
		if not queues[bus].is_empty() and not available[bus].is_empty():


			var player = available[bus].pop_front()
			var audio_stream = queues[bus].pop_front()
			if audio_stream:
				player.stream = audio_stream
				player.play()
			else:
				print("Failed to load audio stream")


func set_background_music_mute(true_or_false):

	background_playing = true_or_false
	var _this_bus_index = AudioServer.get_bus_index("Background")
	if(background_playing):
		background_player.stream = background_music
		background_player.play()
		AudioServer.set_bus_mute(_this_bus_index,false)
		GameManager.save_background_music_choice(background_playing)
	else:
		background_player.stop()
		AudioServer.set_bus_mute(_this_bus_index,true)
		GameManager.save_background_music_choice(background_playing)
	pass # Replace with function body.





func get_background_music_status():
	return background_playing

func set_game_music_mute(true_or_false):
	game_effects_playing = true_or_false

	var _this_bus_index = AudioServer.get_bus_index("Game")
	if(game_effects_playing):
		AudioServer.set_bus_mute(_this_bus_index,false)
		GameManager.save_game_effects_choice(game_effects_playing)
	if(!game_effects_playing):
		AudioServer.set_bus_mute(_this_bus_index,true)
		GameManager.save_game_effects_choice(game_effects_playing)
	pass # Replace with function body.

func get_game_music_status():
	return game_effects_playing

func update_background_music(value):

	background_level = value
	var _this_bus_index = AudioServer.get_bus_index("Background")
	AudioServer.set_bus_volume_db(_this_bus_index,linear_to_db(value))
	GameManager.save_background_music_value(value)

	pass


func get_background_music_level():
	return background_level


func update_game_music(value):
	game_effects_level = value
	var _this_bus_index = AudioServer.get_bus_index("Game")
	AudioServer.set_bus_volume_db(_this_bus_index,linear_to_db(value))
	GameManager.save_game_effects_value(game_effects_level)
	pass


func get_game_music_level():

	return game_effects_level
