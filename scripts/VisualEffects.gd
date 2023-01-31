class_name VisualEffects
extends Node2D


var _tweens: Array[Tween]
var is_tween_card_move_plays: bool:
	get: return _tweens.size() > 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.visual_effects = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_root_controller_on_wrong_release(released_stick: Stick):
	released_stick.show_card(true)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(released_stick, "position", released_stick.start_pos, 0.4)
	tween.tween_callback(func(): on_card_returned(released_stick, tween))
	_tweens.append(tween)


func on_card_returned(released_stick, tween):
	Global.on_card_move_back.emit(released_stick)

	print("id {0}".format([released_stick.id]))
	print("cur pos {0}".format([released_stick.position]))
	print("origin pos {0}".format([released_stick.start_pos]))

	_tweens.erase(tween)
