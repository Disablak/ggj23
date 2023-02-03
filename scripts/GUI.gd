class_name GUI
extends Control


@onready var btn_start: Button = $ButtonStart
@onready var water: Control = $Water
@onready var label_water: Label = $Water/LabelWater
@onready var label_score: Label = $LabelScore
@onready var label_lvl: Label = $LabelLvl
@onready var box_container: HBoxContainer = $HBoxContainer
@onready var fade: ColorRect = $Fade

const FADE_TIME := 1
const LABEL_WATER_TWEEN_DURATION := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.gui = self

	Global.on_updated_water.connect(_on_updated_water)
	Global.on_changed_level.connect(_on_changed_level)
	Global.on_changed_score.connect(_on_changed_score)

	water.visible = false
	fade.visible = true
	label_score.visible = false
	label_lvl.visible = false

	await get_tree().process_frame
	for child in box_container.get_children():
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false


func _on_changed_level(id: int):
	label_lvl.text = "L{0}".format([id])


func _on_changed_score(score: int):
	label_score.text = "S{0}".format([score])


func _on_updated_water(prev_value: int, cur_value: int):
	if prev_value == cur_value:
		return

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_label_water_text, prev_value,
		cur_value, LABEL_WATER_TWEEN_DURATION)
	tween.tween_property(label_water, "scale",
		Vector2(1.2, 1.2), 0.2).from(Vector2.ONE)
	tween.tween_property(label_water, "scale",
		Vector2.ONE, 0.2)

func set_label_water_text(value: int):
	label_water.label_settings.font_color = Color.WHITE
	label_water.text = "{0}".format([value])


func on_start_move_down():
	btn_start.visible = false


func on_moved_down():
	water.visible = true
	label_lvl.visible = true
	label_score.visible = true


func show_hint_water(cur_water: int, add_water: int):
	label_water.label_settings.font_color = Color.WHITE

	if add_water == 0:
		label_water.text = "{0}".format([cur_water])
		return

	if add_water > 0:
		label_water.text = "{0} + {1}".format([cur_water, add_water])
	else:
		if cur_water + add_water <= 0:
			label_water.label_settings.font_color = Color.RED

		label_water.text = "{0} - {1}".format([cur_water, abs(add_water)])


func fade_show(show) -> Tween:
	var tween = create_tween()
	var color_to = Color.BLACK if show else Color(Color.BLACK, 0.0)
	tween.tween_property(fade, "color", color_to, FADE_TIME)

	return tween


func update_card_pos(count: int):
	for child in box_container.get_children():
		child.visible = false

	Global.card_points.clear()

	for id in count:
		var child = box_container.get_child(id)
		child.visible = true

	await get_tree().process_frame

	for id in count:
		var child = box_container.get_child(id)
		var pos = child.global_position + child.size / 2
		Global.card_points.append(pos)
		child.visible = false

