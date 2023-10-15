extends Node2D

@export var mob_scene: PackedScene
var score

@onready var ScoreTimer : Timer
@onready var MobTimer : Timer
@onready var StartPosition: Marker2D
@onready var Player : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreTimer = get_parent().get_node("ScoreTimer")
	MobTimer = get_parent().get_node("MobTimer")
	StartPosition = get_parent().get_node("StartPosition")
	Player = get_parent().get_node("Player")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func game_over():
	ScoreTimer.stop()
	MobTimer.stop()


func new_game():
#	get_tree().call_group("mobs", "queue_free")

	score = 0
	Player.start(StartPosition.position)
#	StartTimer.start()
	print('hello here')
#	$HUD.update_score(score)
#	$HUD.show_message("Get Ready")

	
func _on_score_timer_timeout():
	score += 1
#	$HUD.update_score(score)

func _on_start_timer_timeout():
	MobTimer.start()
	ScoreTimer.start()
	



func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
