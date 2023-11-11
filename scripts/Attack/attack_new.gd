extends Node2D

@onready var enemy_timer : Timer
@onready var path_enemy_timer : Timer

@onready var player : CharacterBody2D
@onready var rocket_timer : Timer
var lives_lost=1
signal game_start
# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_timer = get_parent().get_node("EnemySpawner/EnemyTimer")
	path_enemy_timer = get_parent().get_node("EnemySpawner/PathEnemyTimer")
	rocket_timer = get_parent().get_node("Player/RocketTimer")
	player = get_parent().get_node("Player")
	player.took_damage.connect(_on_player_hit)

	_game_initialize()
	pass # Replace with function body.
#	enemy_spawn_timer = get_parent().get_node("Enemy_Spawn_Timer")
#	player = get_parent().get_node("Player")

func _game_initialize():
	GameManager.reset_score()
	GameManager.startButtonPressed.connect(_on_play_button_pressed)
	GameManager.set_or_reset_lives(3)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_button_pressed():
	GameManager.set_game_enabled(true)
	enemy_timer.start()
	path_enemy_timer.start()
	rocket_timer.start()

func _on_deathzone_area_entered(area):
	area.queue_free()
	pass # Replace with function body.

func _on_player_hit():
	GameManager.update_lives(-lives_lost)
	
	if(GameManager.get_lives()<=0):
		_game_over()

func _game_over():
	GameManager.set_gameover_panel(true)
	GameManager.set_game_enabled(false)
	enemy_timer.stop()
	path_enemy_timer.stop()
	var enemies = get_tree().get_nodes_in_group("enemies")
	for item in enemies:
		item.queue_free()
	rocket_timer.stop()
	GameManager.check_highscore_and_rank("attack")
