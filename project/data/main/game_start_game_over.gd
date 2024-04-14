extends CanvasLayer

signal start_button_pressed
signal game_over
# Called when the node enters the scene tree for the first time.



func _ready():
	%PlayButton.pressed.connect(_on_play_button_pressed)
	%HomeButtonOnGameover.pressed.connect(_on_home_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func out_of_lives():
	game_over.emit()


func game_start_game_over_initialize( this_start_button_callable, this_game_over_callable):
	start_button_pressed.connect(this_start_button_callable)
	game_over.connect(this_game_over_callable)
	pass

func set_game(flag,title,directions):
	%GameStartPanel.visible = flag
	%Title.text=title
	%Directions.text = directions

	
func _on_play_button_pressed():
	%GameStartPanel.visible = false
	start_button_pressed.emit()
	self.hide()
	pass # Replace with function body.

func set_gameover_panel(flag):
	%GameOverPanel.visible = flag

func set_gamestart_panel(flag):
	%GameStartPanel.visible = flag

func set_gameover_panel_congrats(vis):
	%GameOverPanel.visible = vis
	if(vis):
#		game_over_panel_congrats.play()
		%HighscoreAchieved.visible = true
	else:
#		game_over_panel_congrats.stop()
		%HighscoreAchieved.visible = false
		
func _on_home_button_pressed():
	HUD.home_button_pressed()
	self.hide()