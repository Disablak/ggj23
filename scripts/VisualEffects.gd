extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_root_controller_on_wrong_release(released_stick):
	var twin := create_tween()
	twin.set_trans(Tween.TRANS_CUBIC)
	twin.tween_property(released_stick, "position", released_stick.start_pos, 0.5)
