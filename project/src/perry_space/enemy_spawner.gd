extends Node2D

@onready var enemy_scene = preload("res://src/perry_space/enemy.tscn")

@onready var spawn_positions = $SpawnLocations
signal enemy_spawned(enemy_instance)

var original_enemy_time = 2
@onready var enemy_timer : Timer

func _ready():
	enemy_timer = $EnemyTimer
	enemy_timer.wait_time = original_enemy_time
	pass # Replace with function body.

func _on_enemy_timer_timeout():
	_spawn_enemy()
	pass # Replace with function body.
	
func _spawn_enemy():
	var spawn_positions_array = spawn_positions.get_children()
	var random_spawn_position = spawn_positions_array.pick_random()
	
	var enemy_instance = enemy_scene.instantiate()
	
	enemy_instance.global_position = random_spawn_position.position
	emit_signal("enemy_spawned",enemy_instance)
	enemy_instance.add_to_group("enemies")
	add_child(enemy_instance,true)
