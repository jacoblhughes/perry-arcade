extends Food
@onready var my_sprite: AnimatedSprite2D
signal SnakeFoodReady

# Called when the node enters the scene tree for the first time.
func _ready():
	my_sprite = $AppleSpriteAnimated
	SnakeFoodReady.emit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
