extends CanvasLayer
@export var game_background_texture : Texture
# Called when the node enters the scene tree for the first time.
func _ready():
	%TextureRect.texture = game_background_texture
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass