class_name VisualEffects
extends Node2D


var _tween: Tween
var is_tween_card_move_plays: bool:
	get: return _tween != null and _tween.is_running()


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.visual_effects = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_root_controller_on_wrong_release(released_stick: Stick):
	released_stick.show_card(true)

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(released_stick, "position", released_stick.start_pos, 0.4)
