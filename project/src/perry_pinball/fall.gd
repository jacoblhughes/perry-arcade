extends Area2D

signal pinball_oob

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.is_in_group("ball"):
		HUD.update_lives()
		pinball_oob.emit()
		body.queue_free()
