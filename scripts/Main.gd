extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	print('heeeeere')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():

	pass # Replace with function body.

func _on_snake_pressed():
	get_tree().change_scene_to_file("res://scenes/Snake.tscn")
	pass # Replace with function body.


func _on_simonsays_pressed():
	get_tree().change_scene_to_file("res://scenes/SimonSays/SimonSaysGame.tscn")
	pass # Replace with function body.
