class_name GUI
extends Control


@onready var btn_start: Button = $ButtonStart
@onready var label_water: Label = $LabelWater
@onready var box_container: HBoxContainer = $HBoxContainer
@onready var fade: ColorRect = $Fade

const FADE_TIME := 1
const LABEL_WATER_TWEEN_DURATION := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.gui = self

	Global.on_updated_water.connect(_on_updated_water)

	fade.visible = true

	await get_tree().process_frame
	for child in box_container.get_children():
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false


func _on_updated_water(value: int):
	var tween = create_tween()
	var start_value = label_water.text.split(':')[1].to_int()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_label_water_text, start_value,
		value, LABEL_WATER_TWEEN_DURATION)
	tween.tween_property(label_water, "scale", 
		Vector2(1.1, 1.1), 0.2).from(Vector2.ONE)
	tween.tween_property(label_water, "scale", 
		Vector2.ONE, 0.2)

func set_label_water_text(value: int):
	label_water.text = "WATER: {0}".format([value])


func on_start_move_down():
	btn_start.visible = false


func on_moved_down():
	label_water.visible = true

func show_hint_water(cur_water: int, plus_water):
	label_water.label_settings.font_color = Color.WHITE

	if plus_water == null:
		_on_updated_water(cur_water)
		return

	if plus_water:
		label_water.text = "WATER: {0} + {1}".format([cur_water, Global.PART_WATER])
	else:
		if cur_water - Global.PART_WATER == 0:
			label_water.label_settings.font_color = Color.RED
			label_water.text = "WATER: {0} - {1}".format([cur_water, Global.PART_WATER])
		else:
			label_water.text = "WATER: {0} - {1}".format([cur_water, Global.PART_WATER])


func fade_show(show) -> Tween:
	var tween = create_tween()
	var color_to = Color.BLACK if show else Color(Color.BLACK, 0.0)
	tween.tween_property(fade, "color", color_to, FADE_TIME)

	return tween
