extends Node2D

@onready var enemy_wall = preload("res://scenes/perry_flap/enemy_wall.tscn")
@onready var enemy_wall_2 = preload("res://scenes/perry_flap/enemy_wall_2.tscn")
@onready var enemy_wall_3  = preload("res://scenes/perry_flap/enemy_wall_3.tscn")
var scenes

# Called when the node enters the scene tree for the first time.
func _ready():

	scenes = [enemy_wall, enemy_wall_2, enemy_wall_3]

	# Choose a scene randomly

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): 
	pass

func _on_spawn_timer_timeout():
	var chosen_index = randi() % scenes.size()
	var chosen_scene = scenes[chosen_index].instantiate()

	get_parent().add_child(chosen_scene,true)
	chosen_scene.add_to_group("enemy")
	pass # Replace with function body.
