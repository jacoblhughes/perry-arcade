extends Node

var snakecells = 8

var GRID_SIZE := Vector2(0,0)
var GRID_POSITION := Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _set_play_area_size(item):
	GRID_SIZE = Vector2(item.x,item.y)
	
func _set_play_area_position(item):
	GRID_POSITION = Vector2(item.x,item.y)
